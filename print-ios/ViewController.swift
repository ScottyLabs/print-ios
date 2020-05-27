import UIKit

// Constants
let andrewIDKey = "andrewID"

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Properties
    @IBOutlet weak var andrewIDTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Andrew ID from UserDefaults
        andrewIDTextField.text = UserDefaults.standard.object(forKey: andrewIDKey) as? String
        
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
            UserDefaults.standard.set(newAndrewID, forKey: andrewIDKey)
        }
    }
    
    // Action upon clicking Feedback button
    @IBAction func feedbackClick(_ sender: Any) {
        // Opens URL in Safari
        guard let url = URL(string: "https://stackoverflow.com") else { return }
        UIApplication.shared.open(url)
    }
    

    
}
