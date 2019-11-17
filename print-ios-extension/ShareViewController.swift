import UIKit
import Social
import Alamofire
import SwiftyJSON
import MobileCoreServices

struct persistData {
  static var andrewID = ""
}

class ShareViewController: SLComposeServiceViewController {
    
  override func viewDidLoad() {
    self.placeholder = "Print job title"
  }
    
  override func isContentValid() -> Bool {
    return true
  }
    
  override func didSelectPost() {
    let identifier = kUTTypePDF as String

    if let content = extensionContext!.inputItems.first as? NSExtensionItem {
      if let contents = content.attachments {
        for attachment in contents {
          attachment.loadItem(forTypeIdentifier: identifier, options: nil) { data, error in
            let url = data as! NSURL
            self.alamofireUpload(andrewID: persistData.andrewID, fileURL: url as URL)
          }
        }
      }
    }
        
    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
  }
    
  override func configurationItems() -> [Any]! {
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
      "andrew_id" : persistData.andrewID,
      "copies": "1",
      "sides": "one-sided"
    ]
        
    Alamofire.upload(multipartFormData: { multipartFormData in
            
      // I don't think the order matters for appending
      for (key, value) in parameters {
        multipartFormData.append(value.data(using: .utf8)!, withName: key)
      }
            
      if let firstData = NSData(contentsOf: fileURL) {
        var bytes = [UInt8]()
        var buffer = [UInt8](repeating: 0, count: firstData.length)
        firstData.getBytes(&buffer, length: firstData.length)
        bytes = buffer
        let data : Data = Data(bytes)
                
        // withName has to be file, I think, for the POST API to receive it
        multipartFormData.append(data, withName: "file", fileName: self.contentText + ".pdf", mimeType: "application/pdf")
      }
            
    }, to: "http://apis.scottylabs.org/print/v0/printfile", encodingCompletion: { result in
            
      switch result {
      case .success(let upload, _, _):
                
        upload.responseJSON { response in
          if let JSON = response.result.value {
            if let status = response.response?.statusCode {
              let dict = JSON as! NSDictionary
              switch status {
              case 200:
                fallthrough
              default:
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
        self.showAlert(info: (encodingError) as! String + "\n Encoding failed!")
      }
    })
  }
        
  func showAlert(info:String) {
    let message = info
    let pushPrompt = UIAlertController(title: "Print PDF", message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in })
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
