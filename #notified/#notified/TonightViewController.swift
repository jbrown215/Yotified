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
    
    var checkedInMembers : Array<User> = []
    var atRiskMembers : Array<Report> = []
    
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self
        
        Server.genCheckedIn({
            users in
            self.checkedInMembers = users
            Server.genReports({
                reports in
                self.atRiskMembers = reports
                self.tableView.reloadData()
                
            })
        })
        
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
        
        if (indexPath.section == 1) {
            cell.textLabel?.text = checkedInMembers[indexPath.row].name
        } else {
            cell.textLabel?.text = atRiskMembers[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.section == 1) {
            if let resultController = storyboard!.instantiateViewControllerWithIdentifier("ContactDetailViewController") as? ContactDetailViewController {
                resultController.user = checkedInMembers[indexPath.row]
                self.navigationController?.pushViewController(resultController, animated: true)
            }
        } else {
            if let resultController = storyboard!.instantiateViewControllerWithIdentifier("AdminViewReportViewController") as? AdminViewReportViewController {
                resultController.report = atRiskMembers[indexPath.row]
                self.navigationController?.pushViewController(resultController, animated: true)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let CellIdentifier = "SectionHeader"
        let headerView = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if (section == 0) {
            headerView?.textLabel!.text = "At Risk"
        } else {
            headerView?.textLabel!.text = "Checked In"
        }
        return headerView;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
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
