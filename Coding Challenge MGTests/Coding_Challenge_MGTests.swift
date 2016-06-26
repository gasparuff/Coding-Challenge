//
//  Coding_Challenge_MGTests.swift
//  Coding Challenge MGTests
//
//  Created by Michael Gasparik on 16/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import Coding_Challenge_MG

class Coding_Challenge_MGTests: XCTestCase {
    
    var vc : FlickrPhotoBrowserCollectionViewController!
    
    var photoDetailVC : FlickrPhotoDetailViewController!
    
    var standardTimeout : NSTimeInterval!
    
    let responseFaultyImages = "photosResponseFaulty.json"
    let responseWorkingImages = "photosResponseWorking.json"
    let response2WorkingImages = "photosResponse_2_items.json"
    let response1WorkingImage = "photosResponse_1_item.json"
    let responseBigImage = "kitten.jpg"
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let navigationController = (storyboard.instantiateInitialViewController() as! UINavigationController)
        self.vc = navigationController.topViewController as! FlickrPhotoBrowserCollectionViewController
        self.photoDetailVC = storyboard.instantiateViewControllerWithIdentifier("photoDetailViewController") as! FlickrPhotoDetailViewController
        UIApplication.sharedApplication().keyWindow!.rootViewController = navigationController
        self.standardTimeout = NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForRequest
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    

    // MARK: Viewcontroller testing
    
    func testSearchAndLoadMoreExample() {
        let _ = self.vc.view
        
        let searchTerm = "Kitten"
        
        let searchExpectation = self.expectationWithDescription("Searching for \(searchTerm)")
        let loadMoreExpectation = self.expectationWithDescription("Loading next page")
        
        self.vc.resetSearch()
        self.vc.currentSearchterm = searchTerm
        
        self.vc.searchForTerm(false, completionHandler: { (photoData) in
            XCTAssert(self.vc.collectionView(self.vc.collectionView!, numberOfItemsInSection: 0)==self.vc.photos!.count, "The number of items in the Collectionview does not match the number of items returned from API")
            
            if self.vc.hasMoreItems() {
                self.vc.searchForTerm(true, completionHandler: { (photoData) in
                    XCTAssert(self.vc.collectionView(self.vc.collectionView!, numberOfItemsInSection: 0)==self.vc.photos!.count, "The number of items in the Collectionview does not match the number of items returned from API")
                    loadMoreExpectation.fulfill()
                })
            }else{
                loadMoreExpectation.fulfill()
            }
            
            searchExpectation.fulfill()
        }) { (error) in
            XCTAssert(false, "Error: \(error.localizedDescription)")
        }
        
        waitForExpectationsWithTimeout(self.standardTimeout) { error in
            if let error = error {
                print("Timeout exceeded: \(error.localizedDescription)")
            }
        }
    }
    
    func testNotConnectedToNetworkExample() {
        let _ = self.vc.view
        
        let searchTerm = "Kitten"
        
        let notConnectedExpectation = expectationWithDescription("No network connection")
        let notConnectedCode = Int(CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue)

        stub(isHost("api.flickr.com") && isPath("/services/rest")) { _ in
            let notConnectedError = NSError(domain:NSURLErrorDomain, code:notConnectedCode, userInfo:nil)
            return OHHTTPStubsResponse(error:notConnectedError)
        }

        self.vc.resetSearch()
        self.vc.currentSearchterm = searchTerm
        
        self.vc.searchForTerm(false, completionHandler: { (photoData) in
            XCTAssert(false)
            }) { (error) in
                XCTAssert(self.vc.resultState == .Error, "The result is not erroneous")
                notConnectedExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(self.standardTimeout) { error in
            if let error = error {
                print("Timeout exceeded: \(error.localizedDescription)")
            }
        }
    }
    
    func testHistoryEntryExample() {
        let _ = self.vc.view
        
        let searchTerm = "Kitten"
        let historyExpectation = expectationWithDescription("Adding item to history")
        
        let historyBeforeSearch = Helper.getHistory()
        
        self.vc.resetSearch()
        self.vc.currentSearchterm = searchTerm
        
        self.vc.searchForTerm(false, completionHandler: { (photoData) in
            let historyAfterSearch = Helper.getHistory()
            XCTAssert(historyBeforeSearch.count+1==historyAfterSearch.count, "The search item was not added to the history")
            historyExpectation.fulfill()
        }) { (error) in
            XCTAssert(false, "Error: \(error.localizedDescription)")
        }

        waitForExpectationsWithTimeout(self.standardTimeout) { error in
            if let error = error {
                print("Timeout exceeded: \(error.localizedDescription)")
            }
        }
    }
    
    func testOpenItemFromHistoryExample() {
        let _ = self.vc.view
        let _ = self.photoDetailVC.view
        
        let historyExpectation = expectationWithDescription("Opening item from history")
        
        let history = Helper.getHistory()
        
        XCTAssertFalse(history.isEmpty, "History is empty")
        
        let latestHistoryItem = history.first?.keys.first
        
        XCTAssertNotNil(latestHistoryItem, "Latest history item is nil")
        self.vc.historyItemSelected(latestHistoryItem!) { (photoData) in
            let photo = photoData.photos!.last
            
            self.photoDetailVC.photo = photo
            self.photoDetailVC.loadImage()
            self.vc.performSegueWithIdentifier("seguePhotoDetail", sender: photo)
            
            historyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(self.standardTimeout) { error in
            if let error = error {
                print("Timeout exceeded: \(error.localizedDescription)")
            }
        }
    }
    
    func testOpenImageDetailExample() {
        
        let _ = self.vc.view
        let _ = self.photoDetailVC.view
        
        let searchTerm = "Kitten"
        let imageDetailExpectation = expectationWithDescription("Loading image detail")
        
        self.vc.resetSearch()
        self.vc.currentSearchterm = searchTerm
        
        self.vc.searchForTerm(false, completionHandler: { (photoData) in
            let photo = photoData.photos!.last
            
            self.photoDetailVC.photo = photo
            self.photoDetailVC.loadImage()
            self.vc.performSegueWithIdentifier("seguePhotoDetail", sender: photo)
            
            imageDetailExpectation.fulfill()
            }) { (error) in
        }
        
        waitForExpectationsWithTimeout(self.standardTimeout) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: API Client tests
    
    func testAPIClientSearchExample(){
        let searchTerm = "Kitten"
        
        let searchExpectation = expectationWithDescription("Searching for \(searchTerm)")
        
        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            XCTAssertNotNil(response, "No photos have been returned from the API")
            searchExpectation.fulfill()
        }) { (error) in
            XCTAssert(false, "Error: \(error.localizedDescription)")
        }
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Mocked responses
    func testAPIClientSearchResponseStatFailExample(){
        let searchTerm = "Kitten"
    
        let stateExpectation = expectationWithDescription("Returning wrong state from server")
        
        let photosJSON = []
        
        let stubbedJSON = [
            "stat": "fail",
            "photos": photosJSON
            ]
        
        stub(isHost("api.flickr.com")) { _ in
            return OHHTTPStubsResponse(
                JSONObject: stubbedJSON,
                statusCode: 200,
                headers: .None
            )
        }
        
        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            XCTAssert(false, "The response should be erroneous")
        }) { (error) in
            stateExpectation.fulfill()
            print("Error: \(error.localizedDescription)")
        }
        
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAPIClientLoadFaultyImageExample(){
        let searchTerm = "Kitten"
        
        let stateExpectation = expectationWithDescription("Loading wrong image from server")
        
        stub(isHost("api.flickr.com") && isPath("/services/rest")) { _ in
            guard let path = OHPathForFile(self.responseFaultyImages, self.dynamicType) else {
                preconditionFailure("Could not find expected file in test bundle")
            }
            
            return OHHTTPStubsResponse(
                fileAtPath: path,
                statusCode: 200,
                headers: [ "Content-Type": "application/json" ]
            )
        }

        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            
            let firstPhoto = response.photos?.first
            XCTAssertNil(firstPhoto?.thumbnail, "First Photo download did work while it shouldn't")
            stateExpectation.fulfill()
        }) { (error) in
            XCTAssert(false, "Error: \(error.localizedDescription)")
        }
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAPIClientImageDetailNotFoundExample() {
        let searchTerm = "Kitten"
        
        let notFoundExpectation = expectationWithDescription("Loading image which does not exist")
        
        stub(isHost("api.flickr.com") && isPath("/services/rest")) { _ in
            guard let path = OHPathForFile(self.response2WorkingImages, self.dynamicType) else {
                preconditionFailure("Could not find expected file in test bundle")
            }
            return OHHTTPStubsResponse(
                fileAtPath: path,
                statusCode: 200,
                headers: [ "Content-Type": "application/json" ]
            )
        }
        
        stub(isHost("farm8.static.flickr.com")) { _ in
            return OHHTTPStubsResponse(error: NSError(domain: "FlickrSearch", code: 404, userInfo: [NSLocalizedFailureReasonErrorKey:"Not found"]))
        }
        
        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            let secondPhoto = response.photos?[1]
            XCTAssertNotNil(secondPhoto, "secondPhoto is nil")
            FlickrAPIClient.getNetworkImage(secondPhoto!, completion: { (image) in
                
                }, errorBlock: { (error) -> () in
                    if error.code == 404 {
                        notFoundExpectation.fulfill()
                    }
            })
        }) { (error) in
            XCTAssert(false, "did not get any results")
            print("Error: \(error.localizedDescription)")
        }
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func testAPIClientLoadImageSlowNetworkExample() {
        let searchTerm = "Kitten"
        
        let slowNetworkExpectation = expectationWithDescription("Loading image on slow connection")
        
        stub(isHost("api.flickr.com") && isPath("/services/rest")) { _ in
            guard let path = OHPathForFile(self.responseWorkingImages, self.dynamicType) else {
                preconditionFailure("Could not find expected file in test bundle")
            }
            return OHHTTPStubsResponse(
                fileAtPath: path,
                statusCode: 200,
                headers: [ "Content-Type": "application/json" ]
            )
        }
        
        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            let secondPhoto = response.photos?[0]
            XCTAssertNotNil(secondPhoto, "secondPhoto is nil")
            
            stub(isHost("farm8.static.flickr.com")) { _ in
                guard let path = OHPathForFile(self.responseBigImage, self.dynamicType) else {
                    preconditionFailure("Could not find expected file in test bundle")
                }
                return OHHTTPStubsResponse(
                    fileAtPath: path,
                    statusCode: 200,
                    headers: [ "Content-Type": "image/jpeg" ]
                    ).responseTime(OHHTTPStubsDownloadSpeedEDGE)
            }

            
            FlickrAPIClient.getNetworkImage(secondPhoto!, completion: { (image) in
                XCTAssertNotNil(image, "Image is nil")
                slowNetworkExpectation.fulfill()
                }, errorBlock: { (error) -> () in
                    XCTAssert(false, "Error: \(error.localizedDescription)")
                    
            })
        }) { (error) in
            XCTAssert(false, "did not get any results")
            print("Error: \(error.localizedDescription)")
        }
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAPIClientNotConnectedToNetworkExample(){
        let searchTerm = "Kitten"
        
        let offlineExpectation = expectationWithDescription("Loading image on offline connection")
        
        let notConnectedCode = Int(CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue)
        
        stub(isHost("api.flickr.com") && isPath("/services/rest")) { _ in
            let notConnectedError = NSError(domain:NSURLErrorDomain, code:notConnectedCode, userInfo:nil)
            return OHHTTPStubsResponse(error:notConnectedError)
        }
        
        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            XCTAssert(false)
        }) { (error) in
            XCTAssert(error.code == notConnectedCode, "Different error")
            print("errorcode: \(error.code)")
            offlineExpectation.fulfill()
        }
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    //Testing responses from server with wrong data structure
    func testAPIClientSearchWrongResponseExample(){
        let searchTerm = "Kitten"
        
        let errorExpectation = expectationWithDescription("Returning incorrect data structure from server")
        
        let stubbedJSON = [
            "id": 123,
            "foo": "some text",
            "bar": "some other text",
            ]
        
        stub(isHost("api.flickr.com") && isPath("/services/rest")) { _ in
            // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
            return OHHTTPStubsResponse(
                JSONObject: stubbedJSON,
                statusCode: 200,
                headers: .None
            )
        }
        
        let request = FlickrAPIClient.fetchResults(searchTerm, page: 0, completionBlock: { (response) in
            XCTAssert(false, "The response should be erroneous")
        }) { (error) in
            errorExpectation.fulfill()
            print("Error: \(error.localizedDescription)")
        }
        
        XCTAssertNotNil(request?.request?.timeoutInterval, "Request is nil")
        waitForExpectationsWithTimeout((request!.request?.timeoutInterval)!) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Performance
    func testPerformanceExample() {

        // This is an example of a performance test case.
        self.measureBlock {
            let _ = self.vc.view
            
            self.vc.currentSearchterm = "Kitten"
            self.vc.searchForTerm(false) { (photoData) in
                XCTAssert(self.vc.photos?.count>0)
            }
        }
    }
    
}
