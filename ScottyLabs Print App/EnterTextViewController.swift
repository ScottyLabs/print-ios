//
//  EnterTextViewController.swift
//  CMUPrint
//
//  Created by Josh Zhanson on 12/3/16.
//  Copyright © 2016 Josh Zhanson. All rights reserved.
//

import Foundation
import UIKit
import Social
import Alamofire
import SwiftyJSON

// persistData is defined in ViewController
class EnterTextViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var placeholderLabel : UILabel!
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        textView.delegate = self
        
        // Save entered text
        textView.text = persistData.savedEnteredText
        
        placeholderLabel.text = "Your text goes here!"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        
        textView.resignFirstResponder()
        
        let enteredText = textView.text
        persistData.savedEnteredText = enteredText!
        
        showAndrewIDAlert()
        
    }
    
    func alamofireUpload() {
        // NSBundle for getting the path for printText.txt
        let bundle = Bundle.main
        var textPath = bundle.path(forResource: "printText", ofType: "txt")
        
        let fileName = "ScottyLabs.txt"
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as NSString? {
            let path = dir.appendingPathComponent(fileName)
            do {
                try persistData.savedEnteredText.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                print(path)
                print("Text write successful!")
            } catch {
                print("Write failed!")
            }
            do {
                let readingText = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                print(readingText)
            }
            catch {
                print("Read failed!")
            }
            textPath = path
        }
        
        let parameters = [
            "andrew_id" : persistData.andrewID]
        
        // let text = NSData(contentsOfFile: textPath!)
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            // I don't think the order matters for appending
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                print("append successful")
            }
            
            if let firstData = NSData(contentsOfFile: textPath!) {
                var bytes = [UInt8]()
                var buffer = [UInt8](repeating: 0, count: firstData.length)
                firstData.getBytes(&buffer, length: firstData.length)
                bytes = buffer
                
                let data : Data = Data(bytes)
                
                // withName has to be file, I think, for the POST API to receive it
                
                // A different file name instead of just ScottyLabs?
                multipartFormData.append(data, withName: "file", fileName: "ScottyLabs.txt", mimeType: "text/plain")
                print("data is made data")
            }
            
            
            // Real API secret URL: http://apis.scottylabs.org/supersecrethash0123456789/howdidyouguessthis/goodjob/print/printfile
            // http://localhost:5000
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
                                        self.showAlert(info: (message as! String) + "\n Status code: \(statusCode)")
                                    }
                                }
                            default:
                                // It appears that this case is never reached
                                if let message = dict["message"] {
                                    if let statusCode = dict["status_code"] {
                                        self.showAlert(info: (message as! String) + "\n Status code: \(statusCode)")
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                self.showAlert(info: (encodingError) as! String + "\n Encoding failed!")
            }
            
        })
        
    }
 
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        self.dismiss(animated: true)
    }
    
    func showAlert(info: String) {
        let message = info
        let pushPrompt = UIAlertController(title: "Print text",
                                           message: message,
                                           preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,
                               handler: { (action: UIAlertAction!) in
                                    self.dismiss(animated: true)
                                })
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
