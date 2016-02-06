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
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var whereTextField : UITextField!
    @IBOutlet var checkbox1 : UIButton!
    @IBOutlet var checkbox2 : UIButton!
    @IBOutlet var checkbox3 : UIButton!
    @IBOutlet var checkbox4 : UIButton!
    @IBOutlet var anonLabel : UILabel!
    @IBOutlet var whatLabel : UILabel!
    @IBOutlet var whereLabel : UILabel!
    @IBOutlet var whoLabel : UILabel!
    @IBOutlet var drunkLabel : UILabel!
    @IBOutlet var sexualLabel : UILabel!
    @IBOutlet var drugLabel : UILabel!
    @IBOutlet var otherLabel : UILabel!
    @IBOutlet var submitButton : UIButton!
    var reportID : String = ""
    
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
        
        scrollView.delegate = self
        
        
        for troubleOption in roster {
            selectedMap[troubleOption] = false;
        }
        

        anonLabel.center.y = 50
        anonLabel.frame.origin.x = 30
        sliderSwitch.center.y = 50
        sliderSwitch.frame.origin.x = 30 + anonLabel.frame.width
        whatLabel.center.y = 100
        whatLabel.frame.origin.x = 30
        drugLabel.center.y = 150
        drugLabel.frame.origin.x = 80
        checkbox1.center.y = 150
        checkbox1.frame.origin.x = 30
        drunkLabel.center.y = 190
        drunkLabel.frame.origin.x = 80
        checkbox2.center.y = 190
        checkbox2.frame.origin.x = 30
        sexualLabel.center.y = 230
        sexualLabel.frame.origin.x = 80
        checkbox3.center.y = 230
        checkbox3.frame.origin.x = 30
        otherLabel.center.y = 270
        otherLabel.frame.origin.x = 80
        checkbox4.center.y = 270
        checkbox4.frame.origin.x = 30
        whereLabel.center.y = 310
        whereLabel.frame.origin.x = 30
        whereTextField.center.y = 360
        whoLabel.center.y = 410
        whoLabel.frame.origin.x = 23
        searchBar.center.y = 460
        searchBar.frame.origin.x = 23
        tableView.center.y = searchBar.center.y + searchBar.bounds.height
        tableView.frame.origin.x = 31
        submitButton.center.y = 560
        submitButton.frame.origin.x = 30
        
        
        
        scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, tableView.center.y + 300);
        
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
        self.searchBar.text = filtered[row]
        tableView.hidden = true
        searchBar.resignFirstResponder()
        print(sliderSwitch.on)
        print(selectedMap)
    }
    
    
    @IBAction func onBackPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func checkbox1Pressed() {
        checkbox1.selected = !checkbox1.selected
    }

    @IBAction func checkbox2Pressed() {
        checkbox2.selected = !checkbox2.selected
    }
    
    @IBAction func checkbox3Pressed() {
        checkbox3.selected = !checkbox3.selected
    }
    
    @IBAction func checkbox4Pressed() {
        checkbox4.selected = !checkbox4.selected
    }
    
    @IBAction func submitPressed() {
        Server.reportInfo(whereTextField.text!, drunk: checkbox2.selected, assault: checkbox3.selected, drugs: checkbox1.selected, other: checkbox4.selected, needs_help: searchBar.text!, reportId: reportID, anon: sliderSwitch.on, senderId: 6102466685)
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
