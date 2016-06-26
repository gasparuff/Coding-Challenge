//
//  PhotosResponse.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 16/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import ObjectMapper

class PhotosResponse: Mappable {
    
    var photosMeta : PhotosMeta?
    var stat : String?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        photosMeta <- map["photos"]
        stat <- map["stat"]
    }
}
