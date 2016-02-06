//
//  ReportViewController.swift
//  #notified
//
//  Created by Benjamin Lichtman on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {

    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var sliderSwitch : UISwitch!
    @IBOutlet var whereTextField : UITextField!
    
    let textCellIdentifier = "TextCell"
    
    let roster = ["Caroline Hermans", "Frieder", "JB MOTHAFUCKA"]
    var filtered:[String] = []
    var searchActive : Bool = false
    var selectedMap = [String: Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.hidden = true
        whereTextField.delegate = self
        
        for troubleOption in roster {
            selectedMap[troubleOption] = false;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TextField delegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Search bar protocol methods
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = roster.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false
            tableView.hidden = true
        } else {
            searchActive = true
            tableView.hidden = false
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Tableview protocol methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return roster.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if(searchActive){
            if (indexPath.row < filtered.count) {
                cell.textLabel?.text = filtered[indexPath.row]
            }
        } else {
            cell.textLabel?.text = roster[indexPath.row];
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        selectedMap[roster[row]] = !selectedMap[roster[row]]!
        self.searchBar.text = roster[row]
        tableView.hidden = true
        searchBar.resignFirstResponder()
        print(sliderSwitch.on)
        print(selectedMap)
    }
    
    @IBAction func dismissModal(segue:UIStoryboardSegue) {
        print ("Unwindeded")
    }
    
    @IBAction func onBackPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation
    */

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "POST_REPORT") {
            let dest : PostReportViewController = segue.destinationViewController as! PostReportViewController
            dest.selectedMap = self.selectedMap
        }
    }

}
