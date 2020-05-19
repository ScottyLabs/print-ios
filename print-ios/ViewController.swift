import UIKit

// Constants
let andrewIDKey = "andrewID"

class ViewController: UIViewController {

  @IBOutlet weak var andrewIDTextField: UITextField!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load Andrew ID from UserDefaults
    andrewIDTextField.text = UserDefaults.standard.object(forKey: andrewIDKey) as? String
  }
  
  // TODO: It should be updated upon finish instead of change
  // Also, it should have a "Save" button
  @IBAction func onAndrewIDChange() {
    if let newAndrewID = andrewIDTextField.text {
      print("Setting New Andrew ID: \(newAndrewID)")
      UserDefaults.standard.set(newAndrewID, forKey: andrewIDKey)
    }
  }

}
