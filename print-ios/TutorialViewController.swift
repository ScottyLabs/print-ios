import UIKit
import Alamofire
import SwiftyJSON

class TutorialViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
  override var prefersStatusBarHidden: Bool {
    return true
  }
    
  @IBAction func shareButton(sender: UIBarButtonItem) {
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
      "andrew_id" : persistData.andrewID,
      "copies": "1",
      "sides": "one-sided"
    ]
    
    Alamofire.upload(multipartFormData: { multipartFormData in
            
      // I don't think the order matters for appending
      for (key, value) in parameters {
        multipartFormData.append(value.data(using: .utf8)!, withName: key)
      }
            
      if let firstData = NSData(contentsOfFile: samplePath!) {
        var bytes = [UInt8]()
        var buffer = [UInt8](repeating: 0, count: firstData.length)
        firstData.getBytes(&buffer, length: firstData.length)
        bytes = buffer
        let data : Data = Data(bytes)
                
        // withName has to be file, I think, for the POST API to receive it
        multipartFormData.append(data, withName: "file", fileName: "sample.pdf", mimeType: "application/pdf")
      }
            
    }, to: "https://apis.scottylabs.org/print/v0/printfile", encodingCompletion: { result in
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
                    self.showSampleAlert(info: (message as! String) + "\n Status code: \(statusCode)")
                  }
                }
              }
            }
          }
        }
            
      case .failure(let encodingError):
        self.showSampleAlert(info: (encodingError) as! String + "\n Encoding failed!")
      }
    })
  }
    
  func displayShareSheet(shareContent:Any) {
    let activityViewController = UIActivityViewController(activityItems: [shareContent as! URL], applicationActivities: nil)
    present(activityViewController, animated: true, completion: {})
  }
    
  func showSampleAlert(info: String) {
    let pushPrompt = UIAlertController(title: "Print sample", message: info, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in })
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
