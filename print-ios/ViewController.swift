import UIKit

// Constants
let andrewIDKey = "andrewID"

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Properties
    @IBOutlet weak var andrewIDTextField: UITextField!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var feedbackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Andrew ID from UserDefaults
        andrewIDTextField.text = UserDefaults.standard.object(forKey: andrewIDKey) as? String
        
        // Make this controller the delegate for the text field
        andrewIDTextField.delegate = self
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let newAndrewID = textField.text {
            print("Setting New Andrew ID: \(newAndrewID)")
            UserDefaults.standard.set(newAndrewID, forKey: andrewIDKey)
        }
    }
    
    
    

    
}
