//
//  CheckedInViewController.swift
//  #notified
//
//  Created by Benjamin Lichtman on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit

class CheckedInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkOut() {
        print("I'm Home!")
    }
    
    @IBAction func makeReport() {
        print("Making Report!")
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
