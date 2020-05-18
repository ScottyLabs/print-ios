import UIKit

// Constants
let andrewIDKey = "andrewID"

class TutorialViewController: UIViewController {

  @IBOutlet weak var andrewIDTextField: UITextField!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load Andrew ID from UserDefaults
    andrewIDTextField.text = UserDefaults.standard.object(forKey: andrewIDKey) as? String
  }
  
  @IBAction func onAndrewIDChange() {
    if let newAndrewID = andrewIDTextField.text {
      print("Setting New Andrew ID: \(newAndrewID)")
      UserDefaults.standard.set(newAndrewID, forKey: andrewIDKey)
    }
  }

}
