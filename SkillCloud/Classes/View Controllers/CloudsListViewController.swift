//
//  CloudsListViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 31/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

let ShowCloudViewSegueIdentifier = "ShowCloudView"
let CloudCellIdentifier = "CloudCell"

class CloudsListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        return formatter
    }()
    var clouds: [GraphCloudEntity] = []
    var selectedCloud: GraphCloudEntity? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedCloud = nil
        
        DataManager.fetchAll(GraphCloudEntity.self)
        .then { entities -> Void in
            self.clouds = entities
            self.tableView.reloadData()
        }
        .error { error in
            DDLogError("Error fetching clouds: \(error)")
        }
    }
    
    // MARK: - Actions
    @IBAction func addCloudAction(sender: AnyObject) {
        self.performSegueWithIdentifier(ShowCloudViewSegueIdentifier, sender: self)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case ShowCloudViewSegueIdentifier:
            (segue.destinationViewController as? CloudViewController)?.cloudEntity = self.selectedCloud
        default:
            break
        }
    }

}

extension CloudsListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clouds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CloudCellIdentifier)!
        let cloud = self.clouds[indexPath.row]
        
        cell.detailTextLabel?.text =  self.dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: cloud.date))
        cell.textLabel?.text = "\(cloud.cloudId!): \(cloud.name ?? "no name")"
        
        return cell
    }
    
}

extension CloudsListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedCloud = self.clouds[indexPath.row]
        self.performSegueWithIdentifier(ShowCloudViewSegueIdentifier, sender: self)
    }
    
}