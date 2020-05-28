//
//  ActionViewController.swift
//  print-ios-extension
//
//  Created by Arvin Wu on 2/1/20.
//  Modified by Richard Guo
//  Copyright © 2020 ScottyLabs. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire


class ActionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate { //,UIDocumentPickerDelegate,UINavigationControllerDelegate {
    
    // MARK: Variables
    var andrewID: String?
    var fileName: String?
    var selectedOptionIndex = 0
    
    
    // MARK: Outlets
    // text fields
    @IBOutlet weak var andrewIDTextField: UITextField!
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var printOptionTextField: UITextField!
    // for num copies
    @IBOutlet weak var numCopiesLabel: UILabel!
    @IBOutlet weak var numCopiesStepper: UIStepper!
    
    
    
    // MARK: Initialization
    
    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // perform initializations
        initializeAndrewIDTextField()
        initializeFileNameTextField()
        initializePrintOptions()
        initializeNumCopies()
    }
    
    
    
    // MARK: UITextFieldDelegate
    // I'm handling multiple text fields using switch statements... best way to do it
    // according to multiple Stack Overflow posts...
    // This is where I'm handling all the text fields
    
    // Started editing text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch (textField) {
        case printOptionTextField:
            // This is to create the cool picker view for print options
            createPickerView()
        default:
            return
        }
    }
    
    // Clicked "Done" in keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // Finished editing text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField) {
        case andrewIDTextField:
            handleAndrewIDEndEditing(textField)
        case fileNameTextField:
            handleFileNameEndEditing(textField)
        default:
            return
        }
        
    }
    
    
    
    // MARK: Andrew ID Text Field
    
    // initializes andrew id text field
    func initializeAndrewIDTextField() {
        // set text field delegates
        andrewIDTextField.delegate = self
        
        // get andrew ID from UserDefaults
        
    }
    
    // called when andrew id text field is done editing
    func handleAndrewIDEndEditing(_ textField: UITextField) {
        andrewID = textField.text
        print("Set Andrew ID to " + (andrewID ?? "nil"))
    }
    
    
    
    // MARK: File Name Text Field
    
    // initializes file name text field
    func initializeFileNameTextField() {
        // set text field delegates
        fileNameTextField.delegate = self
        
        // get file name from extension context
        if let content = extensionContext!.inputItems.first as? NSExtensionItem {
            if let contents = content.attachments {
                for attachment in contents {
                    fileName = attachment.suggestedName
                }
            }
        }
        // simple nil check
        fileNameTextField.text = fileName
    }
    
    // called when file name text field is done editing
    func handleFileNameEndEditing(_ textField: UITextField) {
        fileName = textField.text
        print("Set File Name to " + (fileName ?? "nil"))
    }

    
    
    // MARK: Print Option Picker
    
    // to be viewed via picker UI
    // this corresponds to printAPIOptions defined below
    let options = ["One-sided",
                   "Two-sided (portrait)",
                   "Two-sided (landscape)"]
    
    // just to initialize the text field
    func initializePrintOptions() {
        // set delegate
        printOptionTextField.delegate = self
        
    }
    
    // This creates a picker view upon selecting the print option text field
    // reference https://medium.com/@raj.amsarajm93/create-dropdown-using-uipickerview-4471e5c7d898
    func createPickerView() {
        // create new UIPickerView object and set inputView
        let pickerView = UIPickerView()
        pickerView.delegate = self
        printOptionTextField.inputView = pickerView
        
        // create "Done" button at top for dismissal
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.endPrintOptionsAction))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        printOptionTextField.inputAccessoryView = toolBar
    }
    // goes with the above
    @objc func endPrintOptionsAction() {
        view.endEditing(true)
    }
    
    
    
    // MARK: UIPickerDelegate
    // This is the delegate for the UI Picker that is created in createPickerView
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedOption = options[row]
        selectedOptionIndex = row
        printOptionTextField.text = selectedOption
        print("Set Print Option to " + selectedOption)
    }
    
    
    
    // MARK: Num Copies
    
    // initializes information for num copies
    func initializeNumCopies() {
        //for stepper
        numCopiesStepper.wraps = false
        numCopiesStepper.autorepeat = true
        numCopiesStepper.maximumValue = 100
        numCopiesStepper.minimumValue = 1
    }
    
    // sets new text of num copies upon stepper value change
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let numCopies = Int(sender.value)
        var copiesText = "copies"
        if (numCopies == 1) {
            copiesText = "copy"
        }
        numCopiesLabel.text = String(numCopies) + " " + copiesText
    }
    
    
    
    // MARK: Print
    
    // for the request to print API
    // this corresponds to options array defined above
    let printAPIOptions = ["one-sided",
                           "two-sided-long-edge",
                           "two-sided-short-edge"]
    
    // Upon clicking print button
    @IBAction func printClick(_ sender: Any) {
        let identifier = kUTTypePDF as String
        
        // nil check the andrew ID and file name
        guard let safeAndrewID = andrewID else {
            showAlert(info: "Andrew ID cannot be blank")
            return
        }
        guard let safeFileName = fileName else {
            showAlert(info: "File Name cannot be blank")
            return
        }
        
        if let content = extensionContext!.inputItems.first as? NSExtensionItem {
            if let contents = content.attachments {
                for attachment in contents {
                    attachment.loadItem(forTypeIdentifier: identifier, options: nil) { data, error in
                        let url = data as! NSURL
                        self.alamofireUpload(andrewID: safeAndrewID, fileName: safeFileName, fileURL: url as URL)
                    }
                }
            }
        }
        // Note: The extension is not terminated here. Instead, the extension is terminated in the callback to alamoFireUpload
    }
    
    // uploads via AlamoFire
    func alamofireUpload(andrewID: String, fileName: String, fileURL: URL) {
        let parameters = [
            "andrew_id" : andrewID,
            "copies": "1",
            "sides": "one-sided"
        ]
        print("Sending request with andrewID:\(andrewID), fileName:\(fileName)")
        
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
                multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: "application/pdf")
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
                                        self.showAlertWithHandler(info: (message as! String) + "\n Status code: \(statusCode)",
                                            handler: { (action: UIAlertAction!) in
                                                self.endExtensionView()
                                        })
                                        print("print API success")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            case .failure(let encodingError):
                self.showAlertWithHandler(info: (encodingError) as! String + "\n Encoding failed!", handler: { (action: UIAlertAction!) in self.endExtensionView()})
                print("print API failure")
            }
            
        })
    }
    
    
    // MARK: Done button
    
    // Upon clicking the done button at the top
    @IBAction func done() {
        endExtensionView()
    }
    
    
    
    // MARK: Utilities
    
    // shows a little alert
    func showAlert(info: String) {
        let message = info
        let pushPrompt = UIAlertController(title: "Print PDF", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in })
        pushPrompt.addAction(ok)
        present(pushPrompt, animated: true, completion: nil )
    }
    
    // shows alert, calls handler
    // handler is a lambda function to be called after clicking "OK"
    func showAlertWithHandler(info: String, handler: ((UIAlertAction) -> Void)?) {
        let message = info
        let pushPrompt = UIAlertController(title: "Print PDF", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: handler)
        pushPrompt.addAction(ok)
        present(pushPrompt, animated: true, completion: nil )
    }
    
    // used to terminate extension view
    func endExtensionView() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        // Basically it doesn't modify the page, unlike other action extensions
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    
}

