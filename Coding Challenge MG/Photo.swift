//
//  Photo.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 16/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import ObjectMapper

class Photo: Mappable {
    
    var id : String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
    
    var thumbnail : UIImage?
    
    required init?(_ map: Map) {
        mapping(map)
        downloadImage()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        owner <- map["owner"]
        secret <- map["secret"]
        server <- map["server"]
        farm <- map["farm"]
        title <- map["title"]
        
    }
    
    func downloadImage(){
        if let imageData = NSData(contentsOfURL: NSURL(string: getImageUrl("m"))!) {
            thumbnail = UIImage(data: imageData)
        }
    }
    
    func getImageUrl(size:String = "m") -> String!{
        if(farm != nil && server != nil && id != nil && secret != nil){
            return "https://farm\(farm!).static.flickr.com/\(server!)/\(id!)_\(secret!)_\(size).jpg"
        }
        return ""
    }
}
