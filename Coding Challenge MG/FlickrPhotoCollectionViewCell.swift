//
//  FlickrPhotoCollectionViewCell.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 19/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit
import Alamofire

class FlickrPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!    
    var photo: Photo!
        
    func configure(photo: Photo) {
        self.photo = photo
        reset()
        if let photo = photo.thumbnail{
            populateCell(photo)
        }
    }
    
    func reset() {
        photoImageView.image = nil
    }
    
    func populateCell(image: UIImage) {
        photoImageView.image = image
    }
}
