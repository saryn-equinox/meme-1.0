//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by 邱浩庭 on 13/12/2020.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraItem: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    let topTextFieldDelegate = TopTextFieldDelegate()
    let bottomTextFieldDelegate = BottomTextFieldDelegate()
    
    var memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0 // set to negative otherwise foregroundColor won't apply
        // https://stackoverflow.com/questions/47774748/swift-nsattributedstringkey-not-applying-foreground-color-correctly
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
        topText.borderStyle = .none
        bottomText.borderStyle = .none
        
        topText.alpha = 0
        bottomText.alpha = 0
        
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        
        topText.delegate = topTextFieldDelegate
        bottomText.delegate = bottomTextFieldDelegate
        
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        imagePickerView.contentMode = .scaleAspectFill
        print("load finished")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) // check if the device supports camera
    }
    
    /**
     Pick an image from album
     */
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     Pick an image from camera- taking photo
     */
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
     }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = img
            
            topText.alpha = 1.0
            bottomText.alpha = 1.0
        }
        dismiss(animated: true, completion: nil)
    }
}

