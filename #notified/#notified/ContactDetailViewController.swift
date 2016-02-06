//
//  ContactDetailViewController.swift
//  #notified
//
//  Created by Jordan Brown on 2/6/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    @IBOutlet var label : UILabel!
    
    var name : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = name

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
