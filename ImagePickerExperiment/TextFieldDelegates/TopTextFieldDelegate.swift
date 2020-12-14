//
//  TopTextFieldDelegate.swift
//  ImagePickerExperiment
//
//  Created by 邱浩庭 on 13/12/2020.
//

import Foundation
import UIKit

class TopTextFieldDelegate: NSObject, UITextFieldDelegate {
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
