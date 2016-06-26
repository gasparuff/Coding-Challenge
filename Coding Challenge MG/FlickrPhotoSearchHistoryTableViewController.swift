//
//  FlickrPhotoSearchHistoryTableViewController.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 22/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit

private let reuseIdentifier = "historyCell"

class FlickrPhotoSearchHistoryTableViewController: UITableViewController {

    var historyEntries : [Dictionary<String, String>]?
    
    var delegate : FlickrHistoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        historyEntries = Helper.getHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = historyEntries?.count{
            return count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

        if let historyEntry = historyEntries?[indexPath.row] {
            cell.textLabel?.text = historyEntry.keys.first
            cell.detailTextLabel?.text = "\(historyEntry.values.first!) hits"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let historyEntry = historyEntries?[indexPath.row] {
            if let searchTerm = historyEntry.keys.first{
                self.delegate?.historyItemSelected(searchTerm, completionHandler: nil)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
