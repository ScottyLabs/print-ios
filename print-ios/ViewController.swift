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
  }
    
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }
    
  override var prefersStatusBarHidden: Bool {
      return true
  }
    
}
