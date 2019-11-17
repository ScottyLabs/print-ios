//
//  ShareViewController.swift
//  ScottyLabs
//
//  Created by Josh Zhanson on 1/2/17.
//  Copyright © 2017 ScottyLabs. All rights reserved.
//

import UIKit
import Social
import Alamofire
import SwiftyJSON
import MobileCoreServices

struct persistData {
    static var andrewID = ""
}

class ShareViewController: SLComposeServiceViewController {
    
    // Note: AndrewID entry is handled by a ConfigurationItem whose tapHandler shows an alert for AndrewID entry. In the future, can use SLComposeServiceViewController's pushConfigurationViewController or in fact a custom view controller for this ShareView Controller to actually present a ScottyLabs view controller that looks like the container app with a UIWebView to show the content, after I figure out how to access the shareContent.
    
    
    override func viewDidLoad() {
        // super.viewDidLoad()
        
        // self.placeholder = "Enter Andrew ID"
        self.placeholder = "Print job title"
        
        print("view did load")
        
    }
    
    //    func handleCompletion(fileURL: NSSecureCoding?, error: NSError!) {
    //
    //        if let fileURL = fileURL as? NSURL {
    //
    //            let newFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appending("test.pdf"))
    //
    //            let fileManager = FileManager.default
    //
    //            do {
    //                try fileManager.copyItem(at: fileURL as URL, to: newFileURL as URL)
    //                // Do further stuff
    //            }
    //            catch {
    //                print(error)
    //            }
    //        }
    //    }
    
    
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    
    
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        print("Did select post!")
        let identifier = kUTTypePDF as String
        
        //        for fileItem in self.extensionContext!.inputItems {
        //
        //            let textItemProvider = (fileItem as! NSExtensionItem).attachments!.first as! NSItemProvider
        //
        //            if textItemProvider.hasItemConformingToTypeIdentifier(identifier) {
        //
        //                textItemProvider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: handleCompletion)
        //            }
        //        }
        
        
        if let content = extensionContext!.inputItems.first as? NSExtensionItem {
            print("first if let!")
            if let contents = content.attachments {
                print("second if let!")
                for attachment in contents {
                    attachment.loadItem(forTypeIdentifier: identifier, options: nil) { data, error in
                        let url = data as! NSURL
                        // let fileExtension = url.pathExtension as String!
                        // let fileName = self.contentText
                        self.alamofireUpload(andrewID: persistData.andrewID, fileURL: url as URL)
                        print("uploaded!")
                    }
                }
            }
        }
        
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        
        let enterAndrewID = SLComposeSheetConfigurationItem()
        enterAndrewID?.title = "AndrewID"
        enterAndrewID?.value = persistData.andrewID
        enterAndrewID?.tapHandler = {
            self.showAndrewIDAlert()
            enterAndrewID?.value = persistData.andrewID
        }
        
        
        return [enterAndrewID!]
    }
    
    func alamofireUpload(andrewID: String, fileURL: URL) {
        
        let parameters = [
            "andrew_id" : persistData.andrewID]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            // I don't think the order matters for appending
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                print("append successful")
            }
            
            if let firstData = NSData(contentsOf: fileURL) {
                var bytes = [UInt8]()
                var buffer = [UInt8](repeating: 0, count: firstData.length)
                firstData.getBytes(&buffer, length: firstData.length)
                bytes = buffer
                
                let data : Data = Data(bytes)
                
                // withName has to be file, I think, for the POST API to receive it
                multipartFormData.append(data, withName: "file", fileName: self.contentText + ".pdf", mimeType: "application/pdf")
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
    
    
    func showAlert(info:String){
        let message = info
        let pushPrompt = UIAlertController(title: "Print PDF",
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
            let andrewID = (pushPrompt.textFields![0].text)!
            persistData.andrewID = andrewID
            self.reloadConfigurationItems()
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
