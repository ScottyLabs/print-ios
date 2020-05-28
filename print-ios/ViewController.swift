import UIKit

// Constants
let andrewIDKey = "andrewID"
let suiteName = "group.org.scottylabs.print-ios"

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Properties
    @IBOutlet weak var andrewIDTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Andrew ID from group UserDefaults
        if let userDefaults = UserDefaults(suiteName: suiteName) {
            andrewIDTextField.text = userDefaults.string(forKey: andrewIDKey)
        } else {
            print("Warning: group (group.org.scottylabs.print-ios) not set properly, andrew id will not be shared")
        }
        
        // Make this controller the delegate for the text field
        andrewIDTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide navigation bar at top
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // show navigation bar at top on next view
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Set the new andrew ID if non-nil
        if let newAndrewID = textField.text {
            // set andrew ID in group user defaults
            if let userDefaults = UserDefaults(suiteName: suiteName) {
                userDefaults.set(newAndrewID, forKey: andrewIDKey)
            } else {
                print("Warning: group (\(suiteName)) not set properly, andrew id will not be shared")
            }
        }
    }
    
    // Action upon clicking Feedback button
    @IBAction func feedbackClick(_ sender: Any) {
        // Opens URL in Safari
        guard let url = URL(string: "https://stackoverflow.com") else { return }
        UIApplication.shared.open(url)
    }
    

    
}
