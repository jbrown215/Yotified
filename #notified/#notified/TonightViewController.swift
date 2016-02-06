//
//  TonightViewController.swift
//  #notified
//
//  Created by Jordan Brown on 2/6/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit

class TonightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var tableView : UITableView!
    
    var checkedInMembers = ["Jordan", "Caroline", "Frieder", "Ben"]
    var atRiskMembers = ["Ben"]
    
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    // MARK: - Tableview protocol methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return atRiskMembers.count
        } else {
            return checkedInMembers.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if (indexPath.row >= atRiskMembers.count) {
            cell.textLabel?.text = checkedInMembers[indexPath.row - atRiskMembers.count]
        } else {
            cell.textLabel?.text = atRiskMembers[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.row >= atRiskMembers.count) {
            if let resultController = storyboard!.instantiateViewControllerWithIdentifier("ContactDetailViewController") as? ContactDetailViewController {
                resultController.name = checkedInMembers[indexPath.row - atRiskMembers.count]
                self.navigationController?.pushViewController(resultController, animated: true)
            }
        } else {
            if let resultController = storyboard!.instantiateViewControllerWithIdentifier("AdminViewReportViewController") as? AdminViewReportViewController {
                resultController.name = atRiskMembers[indexPath.row]
                self.navigationController?.pushViewController(resultController, animated: true)
            }
        }
    }
    
    @IBAction func unwindToTonightView(segue : UIStoryboardSegue) {
        print ("Unwind to tonight view")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
