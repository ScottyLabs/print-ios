import UIKit

// Constants
let andrewIDKey = "andrewID"

class ViewController: UIViewController {
    
    // Properties
    @IBOutlet weak var andrewIDTextField: UITextField!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var feedbackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Andrew ID from UserDefaults
        andrewIDTextField.text = UserDefaults.standard.object(forKey: andrewIDKey) as? String
    }
    
    @IBAction func onAndrewIDEnd(_ sender: Any) {
        if let newAndrewID = andrewIDTextField.text {
            print("Setting New Andrew ID: \(newAndrewID)")
            UserDefaults.standard.set(newAndrewID, forKey: andrewIDKey)
        }
    }
    
}
