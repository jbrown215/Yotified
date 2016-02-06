//
//  ViewController.swift
//  #notified
//
//  Created by Jordan Brown on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func doSomething() {
        print("Test");
    }

}

