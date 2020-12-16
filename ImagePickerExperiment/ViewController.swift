//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created on 13/12/2020.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraItem: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    struct Meme {
        let topText: String
        let bottomText: String
        let originalImage: UIImage!
        let memeImage: UIImage!
        
        init(_ topText: String, _ bottomText: String, _ originalImage: UIImage, _ memeImage: UIImage) {
            self.topText = topText
            self.bottomText = bottomText
            self.originalImage = originalImage
            self.memeImage = memeImage
        }
    }
    
    let topTextFieldDelegate = MemeTextFieldDelegate()
    let bottomTextFieldDelegate = MemeTextFieldDelegate()
    
    var viewOriginY: CGFloat! // this variable used to set the frame back to original postion when keyBoard will hide
    var memes: [Meme] = []
    
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
        setTextFieldParameters(topText, topTextFieldDelegate, "ENTER TOP TEXT")
        setTextFieldParameters(bottomText, bottomTextFieldDelegate, "ENTER BOTTOM TEXT")
        
        imagePickerView.contentMode = .scaleAspectFill
        shareButton.isEnabled = false
        
        viewOriginY = self.view.frame.origin.y
        print("load finished")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) // check if the device supports camera
        // subscribe the keyboard
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // un-subscribe the keyboard
        unsubscribeFromKeyboardNotifications()
    }
    
    // Mark: Configure the parameters
    
    private func setTextFieldParameters(_ textField: UITextField, _ delegate: UITextFieldDelegate, _ text: String){
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = delegate
        textField.textAlignment = .center
        textField.alpha = 0
        textField.borderStyle = .none
        textField.text = text
    }
    
    
    // Mark: Add and Remove listeners for keyboard events
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let temp = getKeyboardHeight(notification)
        print("Will Show: ", separator: "", terminator: "\t")
        print(temp)
        view.frame.origin.y -= temp
    }
    
    /**
     Called when keyboardWillHide
    my app sometimes will call keyboardWillShow twice when is should be called only once. So I keep track of the view.frame original y so that I can guaratnee to get back to the
        right position
     */
    @objc func keyboardWillHide(_ notification: Notification) {
//        let temp = getKeyboardHeight(notification)
//        print("Will Hide: ", separator: "", terminator: "\t")
//        print(temp)
        view.frame.origin.y = viewOriginY
    }
    
    func getKeyboardHeight(_ notificatoin: Notification) -> CGFloat {
        let userInfo = notificatoin.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    /**
     Pick an image from album
     */
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImageFromSource(.photoLibrary)
    }
    
    /**
     Pick an image from camera- taking photo
     */
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImageFromSource(.camera)
     }
    
    /**
     Helper function for picking Images
     */
    private func pickImageFromSource(_ source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = img
            
            topText.alpha = 1.0
            bottomText.alpha = 1.0
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Mark: Save the meme
    
    func save(_ memeImage: UIImage) {
        memes.append(Meme(topText.text!, bottomText.text!, imagePickerView.image!, memeImage))
    }
    
    /**
     Generate an memedImage
     */
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Draw the image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        return memedImage
    }
    
    /**
     Share our meme
     */
    @IBAction func shareMeme(_ sender: Any) {
        let generatedMeme = generateMemedImage()
        let activityVC  = UIActivityViewController(activityItems: [generatedMeme], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { [weak self] type, completed, items, error in

            if completed {
               self?.save(generatedMeme)
            }

            activityVC.dismiss(animated: true, completion: nil)
        }

        present(activityVC, animated: true, completion: nil)
    }

}
