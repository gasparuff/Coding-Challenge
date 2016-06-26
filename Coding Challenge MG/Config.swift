//
//  Config.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 16/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import Foundation
import UIKit

struct Config {
    struct API {
        static let APIKey = "3e7cc266ae2b0e0d78e279ce8e361736"
        static let APIBaseURL = "https://api.flickr.com/services/rest/?"
        static let APISearchURL = APIBaseURL + "method=flickr.photos.search&api_key=" + APIKey + "&format=json&nojsoncallback=1&safe_search=1&per_page=\(ItemsPerPage)"
    }
    
    struct Colors {
        static let MainColor = UIColor.blackColor()
    }
    
    static let ItemsPerPage = 20
    static let NumberOfColumns = 3
    
    struct Keys {
        static let SearchHistory = "SearchHistory"
    }
    
}