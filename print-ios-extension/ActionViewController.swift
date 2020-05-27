//
//  ActionViewController.swift
//  print-ios-extension
//
//  Created by Arvin Wu on 2/1/20.
//  Copyright © 2020 ScottyLabs. All rights reserved.
//

import UIKit
import MobileCoreServices



class ActionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{ //,UIDocumentPickerDelegate,UINavigationControllerDelegate {
    
  var andrewID: String?

  
  @IBOutlet weak var andrewIDTextField: UITextField!
  
  @IBOutlet weak var printOptionTextField: UITextField! //used
    
  @IBOutlet weak var andrewIDLabel: UILabel!
  // useless @IBOutlet weak var printQuantityTextField: UITextField! //deleted

    @IBOutlet weak var printOptionPicker: UIPickerView! //used
  
    //@IBOutlet weak var printQuantityStepper: UIStepper!

  
  
  // for stepper
    @IBOutlet weak var quantityLabel: UILabel!

  @IBOutlet weak var stepper: UIStepper!
  
  @IBAction func stepperValueChanged(_ sender: UIStepper) {
    quantityLabel.text = Int(sender.value).description
  }
  
  @IBAction func PickFile(_ sender: Any) {
    //let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
    //importMenu.delegate = self as? UIDocumentPickerViewController as! UIDocumentPickerDelegate
    //importMenu.modalPresentationStyle = .formSheet
    //self.present(importMenu, animated: true, completion: nil)
  }
  
  @IBAction func printClick(_ sender: Any) {
    //var pdfURL: URL? { get };
    //let filePDF = init?(url: pdfURL);
  }
  
  
  @IBAction func onButtonClick(_ sender: Any) {
    let idText=andrewIDTextField.text!
    andrewID=andrewIDTextField.text!
    andrewIDLabel.text = "Andrew ID: \(idText) "
    print(andrewID)
    print(idText)
    
    //clear text fields
    andrewIDTextField.text=""
  }
  
  
  // for picker
    let options = ["Single-sided",
                   "Double-Sided (long-edge flip)",
                   "Double-Sided (short-edge flip)"]
  
    var selectedOption: String?
  

  //start
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                  guard let myURL = urls.first else {
                       return
                  }
                  print("import result : \(myURL)")
        }


    //public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
            //documentPicker.delegate = self
            //present(documentPicker, animated: true, completion: nil)
        //}


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                print("view was cancelled")
                dismiss(animated: true, completion: nil)
        } // end
  
    override func viewDidLoad() {
        super.viewDidLoad()
        createPrintOptionPicker()
        
        //for stepper
        stepper.wraps = false
        stepper.autorepeat = true
        stepper.maximumValue = 100
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
    }

  

  
  
  func createPrintOptionPicker(){
      printOptionPicker.delegate=self
      printOptionTextField.inputView=printOptionPicker
    }
  
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
  
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
        
        selectedOption = options[row]
        printOptionTextField.text = selectedOption
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
