//
//  Helper.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 22/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import Foundation

class Helper {
    static func getHistory() -> [Dictionary<String, String>] {
        if let history = NSUserDefaults.standardUserDefaults().arrayForKey(Config.Keys.SearchHistory) as? [Dictionary<String, String>] {
            return history
        }
        return Array()
    }
    
    static func addToHistory(searchTerm:String!, result:PhotosMeta){
        var searchHistory = getHistory()
        let searchDictionary = [searchTerm : "\(result.total!)"]
        searchHistory.insert(searchDictionary, atIndex: 0)
        NSUserDefaults.standardUserDefaults().setObject(searchHistory, forKey: Config.Keys.SearchHistory)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}