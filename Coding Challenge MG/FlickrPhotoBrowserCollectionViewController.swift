//
//  FlickrPhotoBrowserCollectionViewController.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 16/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import AVFoundation

private let reuseIdentifier = "Cell"
private let loadingReuseIdentifier = "LoadingCell"

enum CollectionViewState {
    case Searching //While search is active
    case Empty //On start, when no search has been started
    case NoResults //When the API returns 0 items
    case Error //When the API returns an error
}

protocol FlickrHistoryDelegate {
    func historyItemSelected(searchTerm:String, completionHandler:((photoData:PhotosMeta!)->())?)
}

class FlickrPhotoBrowserCollectionViewController: UICollectionViewController, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, FlickrLayoutDelegate, FlickrHistoryDelegate {

    let searchBar = UISearchBar()
    
    var searchResponse : PhotosMeta?
    
    var photos : [Photo]?
    
    var imageCache = [String:UIImage]()

    let contentInsetLeftAndRight : CGFloat = 10
    
    var historyViewController : FlickrPhotoSearchHistoryTableViewController?
    
    private var currentPage : Int = 0
    var currentSearchterm : String? {
        didSet {
            if searchBar.text != currentSearchterm {
                searchBar.text = currentSearchterm
            }
        }
    }
    private var currentlyLoading : Bool = false
    private var currentSearchTotalCount : Int64 = 0
    
    var resultState : CollectionViewState = .Empty
    
    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true
        
        self.setup()
    }
    
    func setup(){
        if let layout = collectionView?.collectionViewLayout as? FlickrLayout {
            layout.delegate = self
        }
        self.searchBar.sizeToFit()
        self.searchBar.placeholder = "Search Flickr"
        self.searchBar.showsCancelButton = false
        self.searchBar.delegate = self
        navigationItem.titleView = self.searchBar
        
        //Setting the DZNEmptyDatasource and Delegate
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self
        
        self.collectionView?.backgroundColor = Config.Colors.MainColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = (segue.destinationViewController as? UINavigationController)?.topViewController as? FlickrPhotoDetailViewController {
            if let photoCell = sender as? FlickrPhotoCollectionViewCell {
                destinationViewController.photo = photoCell.photo
            } else if let photo = sender as? Photo {
                destinationViewController.photo = photo
            }
        }
    }
    
    func openPhotoDetail(photo : Photo){
        
    }
    
    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        self.historyViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.historyViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.historyViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        currentSearchterm = searchBar.text
        searchBar.resignFirstResponder()
        self.resetSearch()
        self.searchForTerm()
        historyViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helpers
    func resetSearch(){
        self.searchResponse = nil
        self.photos = [Photo]()
        let layout = collectionView?.collectionViewLayout as? FlickrLayout
        layout?.resetCache()
        self.currentSearchTotalCount = 0
        self.currentPage = 0
        self.collectionView?.reloadData()
    }
    
    func hasMoreItems() -> Bool{
        return Int64(self.photos!.count) < self.currentSearchTotalCount
    }
    
    func searchForTerm(loadMore : Bool = false, completionHandler:((photoData:PhotosMeta!)->())? = nil, errorBlock:((error:NSError)->())? = nil){
        if let searchTerm = self.currentSearchterm{
            
            self.currentlyLoading = true
            
            //Setting the resultstate, so that the DZNEmptyDatasetDelegate returns the correct text. That's why we need to reload the collectionView.
            self.resultState = .Searching
            self.collectionView?.reloadData()

            FlickrAPIClient.fetchResults(searchTerm, page: currentPage, completionBlock: { (response) in
                    self.processResults(response)
                    if(!loadMore) {
                        Helper.addToHistory(searchTerm, result: response)
                    }
                    completionHandler?(photoData: response)

                }, errorBlock: {(error) in
                    print("Error loading photos: \(error)")
                    self.resultState = .Error
                    self.collectionView?.reloadData()
                    errorBlock?(error:error)
            })
        }
    }
    
    func processResults(searchResponse : PhotosMeta){
        self.searchResponse = searchResponse
        if self.photos == nil {
            self.photos = Array()
        }
        self.photos = self.photos! + searchResponse.photos!
        if let page = searchResponse.page {
            self.currentPage = page
        }
        
        if let totalCount = searchResponse.total {
            self.currentSearchTotalCount = totalCount
            if totalCount == 0 {
                self.resultState = .NoResults
            }
        }
        
        self.collectionView?.reloadData()
        self.currentlyLoading = false
    }
    
    // MARK: Actions
    @IBAction func showHistory(sender: AnyObject) {
        historyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HistoryVC") as? FlickrPhotoSearchHistoryTableViewController
        historyViewController!.delegate = self
        historyViewController!.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = historyViewController!.popoverPresentationController
        
        let historyCount = Helper.getHistory().count
        
        if historyCount < 6 {
            historyViewController!.preferredContentSize = CGSizeMake(300, 44 * CGFloat(historyCount))
        }else {
            historyViewController!.preferredContentSize = CGSizeMake(300, 44 * 6)
        }
        
        popover?.delegate = self
        popover?.sourceView = self.view
        popover?.barButtonItem = sender as? UIBarButtonItem
        
        presentViewController(historyViewController!, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        if let photosCount = self.photos?.count where photosCount > 0 {
            if Int64(photos!.count) < currentSearchTotalCount {
                return 2 // Show 2 sections - one for the results and one for the loading indicator
            }
            return 1
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            if let photosCount = self.photos?.count where photosCount > 0 {
                return photosCount
            }
        case 1:
            return 1
        default:
            return 0
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(loadingReuseIdentifier, forIndexPath: indexPath)
            return cell
        default:
            assert(false, "Must return a collectionviewcell")
        }
    }

    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? FlickrPhotoCollectionViewCell{
            if let photo = self.photos?[indexPath.row] {
                cell.configure(photo)
            }
        }
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "parallaxHeader", forIndexPath: indexPath)
            return view
        }
        
        return UICollectionReusableView(frame: CGRectZero)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, contentInsetLeftAndRight, 0, contentInsetLeftAndRight)
    }
    
    // MARK: FlickrLayout Delegate
    // 1
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
                        withWidth width: CGFloat) -> CGFloat {
        
        
        if let photoSize = self.photos?[indexPath.row].thumbnail?.size {
            let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
            let rect  = AVMakeRectWithAspectRatioInsideRect(photoSize, boundingRect)
            return rect.size.height
        }
        
        return 0
    }
    

    // MARK: UIScrollView Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && !self.currentlyLoading && self.photos?.count>0 && self.hasMoreItems(){
            print("load more")
            self.currentPage = self.currentPage + 1
            self.searchForTerm(true)
        }
    }

    // MARK: DZNEmptyDataSet delegate & datasource
    // The returned Strings should be put into a localizable file to support multiple languages
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var title : String = "";
        
        switch resultState{
        case .Error:
            title = "Error :-("
        case .NoResults:
            title = "No results"
        case .Searching:
            title = "Searching..."
        case .Empty:
            title = "Start searching"
        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: title, attributes: attributes)

    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var description : String = ""
        switch resultState{
        case .Error:
            description = "There has been an error with your search. Please try again later"
        case .NoResults:
            description = "Your search returned no items. Please try again with a different term."
        case .Searching:
            if let searchTerm = currentSearchterm {
                description = "Searching for \(searchTerm)"
            }
        case .Empty:
            description = "Search for Photos by tapping on the search bar above"
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0), NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: description, attributes: attributes)
    }
    
    //MARK: UIPopoverControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle{
        return .None
    }

    //MARK: History Delegate
    func historyItemSelected(searchTerm: String, completionHandler:((photoData:PhotosMeta!)->())? = nil) {
        self.currentSearchterm = searchTerm
        self.searchBar.text = searchTerm
        self.searchBar.resignFirstResponder()
        self.resetSearch()
        self.searchForTerm(false, completionHandler: completionHandler)
    }
    
}
