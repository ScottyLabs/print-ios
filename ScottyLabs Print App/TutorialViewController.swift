//
//  TutorialViewController.swift
//  CMUPrint
//
//  Created by Josh Zhanson on 11/2/16.
//  Copyright © 2016 Josh Zhanson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// persistData is defined in ViewController
class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
        // HERE IS THE SHARECONTENT
        let bundle = Bundle.main
        let samplePath = bundle.url(forResource: "sample", withExtension: "pdf")
        
        displayShareSheet(shareContent: samplePath as Any)
    }
    
    @IBAction func printSampleButton(sender: UIButton) {
        
        showAndrewIDAlert()
        
    }
    
    func alamofireUpload() {
        // NSBundle for getting the path for sample.pdf
        let bundle = Bundle.main
        let samplePath = bundle.path(forResource: "sample", ofType: "pdf")
        
        let parameters = [
            "andrew_id" : persistData.andrewID]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            // I don't think the order matters for appending
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                print("append successful")
            }
            
            if let firstData = NSData(contentsOfFile: samplePath!) {
                var bytes = [UInt8]()
                var buffer = [UInt8](repeating: 0, count: firstData.length)
                firstData.getBytes(&buffer, length: firstData.length)
                bytes = buffer
                
                let data : Data = Data(bytes)
                
                // withName has to be file, I think, for the POST API to receive it
                multipartFormData.append(data, withName: "file", fileName: "sample.pdf", mimeType: "application/pdf")
                print("data is made data")
            }
            
            
            // Real API secret URL: http://apis.scottylabs.org/supersecrethash0123456789/howdidyouguessthis/goodjob/print/printfile
        }, to: "http://apis.scottylabs.org/supersecrethash0123456789/howdidyouguessthis/goodjob/print/printfile", encodingCompletion: { result in
            print(result)
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        
                        if let status = response.response?.statusCode {
                            let dict = JSON as! NSDictionary
                            switch status {
                            case 200:
                                if let message = dict["message"] {
                                    if let statusCode = dict["status_code"] {
                                        self.showSampleAlert(info: (message as! String) + "\n Status code: \(statusCode)")
                                    }
                                }
                            default:
                                // It appears that this case is never reached
                                if let message = dict["message"] {
                                    if let statusCode = dict["status_code"] {
                                        self.showSampleAlert(info: (message as! String) + "\n Status code: \(statusCode)")
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                self.showSampleAlert(info: (encodingError) as! String + "\n Encoding failed!")
            }
            
        })
    }
    
    
    
    func displayShareSheet(shareContent:Any) {
        
        let activityViewController = UIActivityViewController(activityItems: [shareContent as! URL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    func showSampleAlert(info:String){
        let message = info
        let pushPrompt = UIAlertController(title: "Print sample",
                                           message: message,
                                           preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,
                                      handler: { (action: UIAlertAction!) in })
        pushPrompt.addAction(ok)
        present(pushPrompt, animated: true, completion: nil )
        
        
        
    }
    
    func showAndrewIDAlert() {
        let message = "Enter Andrew ID."
        let pushPrompt = UIAlertController(title: "Enter Andrew ID", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            persistData.andrewID = (pushPrompt.textFields![0].text)!
            self.alamofireUpload()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in })
        pushPrompt.addAction(ok)
        pushPrompt.addAction(cancel)
        pushPrompt.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Andrew ID"
        }
        present(pushPrompt, animated: true, completion: nil)
        
    }

}
