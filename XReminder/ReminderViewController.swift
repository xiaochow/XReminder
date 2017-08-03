//
//  ReminderViewController.swift
//  XReminder
//
//  Created by Xiaoxiao on 6/16/17.
//  Copyright © 2017 WangXiaoxiao. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var item : Item?

    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        // Set up delegate
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        // Set the save button to false
        self.checkValidInput()
        
        // Add dismiss keyboard gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReminderViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Set border color of text view
        contentTextView.layer.borderColor = titleTextField.layer.borderColor
        contentTextView.layer.borderWidth = 1.0
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1)]
        

        // Displaying the existed item.
        if let item = item {
            navigationItem.title = "Edit Item"
            titleTextField.text = item.title
            contentTextView.text = item.subtitle
            timePicker.date = item.date
            saveButton.isEnabled = true
        }
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
  
        self.checkValidInput()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //  Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    // MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Disable the save button while typing.
        saveButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.checkValidInput()
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        // Hide the keyboard.
        textView.resignFirstResponder()
        return true
    }

    
    // Check if the input information is valid.
    func checkValidInput(){
        
        let title = titleTextField.text ?? ""
        
        saveButton.isEnabled = !title.isEmpty
    }
    
    
    func dismissKeyboard() {

        // Resign the keyboard
        self.view.endEditing(true)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Dimiss current viewcontroller
        if presentingViewController is UITabBarController {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let button = sender as! UIBarButtonItem! {
            if saveButton === button {
                let title = titleTextField.text ?? ""
                let subtitle = contentTextView.text ?? ""
                let date = timePicker.date
                
                // Set the currency to be passed to  after the unwind segue.
                item = Item(title: title, subtitle: subtitle, date: date)
                
            }
        }
    }

}
