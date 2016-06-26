//
//  PhotosMeta.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 21/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit
import ObjectMapper

class PhotosMeta: Mappable {
    var page : Int?
    var pages: Int?
    var perpage: Int?
    var total: Int64?
    
    var photos : [Photo]?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        page <- map["page"]
        pages <- map["pages"]
        perpage <- map["perpage"]
        total <- (map["total"], TransformOf<Int64, String>(fromJSON: { Int64($0!) }, toJSON: { $0.map { String($0) } }))
        photos <- map["photo"]
    }
}
