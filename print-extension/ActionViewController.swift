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
    
    
    // MARK: Outlets
    
    // text fields
    @IBOutlet weak var andrewIDTextField: UITextField!
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var printOptionTextField: UITextField!
    
    // for num copies
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    
    // MARK: Initialization
    
    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTextFields()
        initializeNumCopies()
        
    }
    // initializes information for text fields
    func initializeTextFields() {
        // set text field delegates
        andrewIDTextField.delegate = self
        fileNameTextField.delegate = self
        printOptionTextField.delegate = self
        
        // get andrew ID from UserDefaults
        
        // get file name from extension context
        if let content = extensionContext!.inputItems.first as? NSExtensionItem {
            if let contents = content.attachments {
                for attachment in contents {
                    fileName = attachment.suggestedName
                }
            }
        }
        fileNameTextField.text = fileName ?? ""
        
    }
    // initializes information for num copies and stepper
    func initializeNumCopies() {
        //for stepper
        stepper.wraps = false
        stepper.autorepeat = true
        stepper.maximumValue = 100
    }
    
    
    // MARK: UITextFieldDelegate
    // I'm handling multiple text fields using switch statements... best way to do it
    // according to multiple Stack Overflow posts...
    
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
            handleFileNameEndEditing()
        case printOptionTextField:
            handlePrintOptionEndEditing()
        default:
            return
        }
        
    }
    
    // MARK: Text Field Handlers
    
    // Set the new andrew ID
    func handleAndrewIDEndEditing(_ textField: UITextField) {
        andrewID = textField.text
    }
    
    func handleFileNameEndEditing() {
        
    }
    
    func handlePrintOptionEndEditing() {
        
    }
    
    // MARK: Buttons
    
//    @IBAction func stepperValueChanged(_ sender: UIStepper) {
//        quantityLabel.text = Int(sender.value).description
//    }
    
    
    
//
//    @IBAction func onButtonClick(_ sender: Any) {
//        let idText=andrewIDTextField.text!
//        andrewID=andrewIDTextField.text!
//        andrewIDLabel.text = "Andrew ID: \(idText) "
//        print(idText)
//
//        //clear text fields
//        andrewIDTextField.text=""
//    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    
    
    
    /*
     //start
     public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
     guard let myURL = urls.first else {
     return
     }
     print("import result : \(myURL)")
     }
     
     
     
     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
     print("view was cancelled")
     dismiss(animated: true, completion: nil)
     } // end
     */
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Option Picker
    
    // for picker
    let options = ["One-sided",
                   "Two-sided (portrait)",
                   "Two-sided (landscape)"]
    
    var selectedOptionIndex = 0
    
    //    func createPrintOptionPicker(){
    //      printOptionPicker.delegate=self
    //      printOptionTextField.inputView=printOptionPicker
    //    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        printOptionTextField.inputView = pickerView
        dismissPickerView()
    }
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        printOptionTextField.inputAccessoryView = toolBar
    }
    @objc func action() {
        view.endEditing(true)
    }
    
    // MARK: UIPickerDelegate
    
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
    }
    
    // MARK: Print
    
    @IBAction func printClick(_ sender: Any) {
        //var pdfURL: URL? { get };
        //let filePDF = init?(url: pdfURL);
        let identifier = kUTTypePDF as String
        guard let safeAndrewID = andrewID else {
            showAlert(info: "Andrew ID cannot be blank")
            return
        }
        
        if let content = extensionContext!.inputItems.first as? NSExtensionItem {
            if let contents = content.attachments {
                for attachment in contents {
                    let fileName = attachment.suggestedName ?? "file"
                    print("fileName:"+fileName)
                    attachment.loadItem(forTypeIdentifier: identifier, options: nil) { data, error in
                        let url = data as! NSURL
                        self.alamofireUpload(andrewID: safeAndrewID, fileName: fileName, fileURL: url as URL)
                    }
                }
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        
        
    }
    
    func alamofireUpload(andrewID: String, fileName: String, fileURL: URL) {
        let parameters = [
            "andrew_id" : andrewID,
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
                                        self.showAlert(info: (message as! String) + "\n Status code: \(statusCode)")
                                        print("success")
                                    }
                                }
                            }
                        }
                    }
                }
                
            case .failure(let encodingError):
                self.showAlert(info: (encodingError) as! String + "\n Encoding failed!")
                print("failure")
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
    

    
    
    
    
    
    
}

/*
 
 // test code
 class MyViewController: UIViewController {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 }
 
 func importFromFiles(origin: UIViewController?) {
 
 let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeContent as String], in: .import)
 documentPicker.delegate = self
 documentPicker.allowsMultipleSelection = true
 
 origin?.present(documentPicker, animated: true, completion: nil)
 
 }
 
 }
 extension MyViewController: UIDocumentPickerDelegate {
 
 func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
 print("Files picked")
 }
 
 }
 */
