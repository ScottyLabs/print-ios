//
//  ViewController.swift
//  ScottyLabs Print App
//
//  Created by Josh Zhanson on 1/2/17.
//  Copyright © 2017 ScottyLabs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct persistData {
    static var andrewID = ""
    static var savedEnteredText = ""
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
    //        return .lightContent
    //    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}

