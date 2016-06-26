//
//  FlickrPhotoDetailViewController.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 22/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit

class FlickrPhotoDetailViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    
    var photo : Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Config.Colors.MainColor
        
        self.loadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Loading image
    func loadImage(){
        if let photo = self.photo {
            self.photoImageView.image = photo.thumbnail
            self.photoTitleLabel.text = photo.title
            //Now load the big image
            FlickrAPIClient.getNetworkImage(photo, completion: { (bigImage) in
                self.photoImageView.image = bigImage
                }, errorBlock: {(error) in
                    print("Error loading photo: \(error)")
            })
        }
    }

    // MARK: Navigation
    
    @IBAction func close(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
