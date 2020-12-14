//
//  MemeTextFieldDelegate.swift
//  ImagePickerExperiment
//
//  Created on 13/12/2020.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    var isFirst = true
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isFirst {
            textField.text = ""
            isFirst = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
