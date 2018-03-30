//
//  UserProfileViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 2/4/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseStorage

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    var storageRef : StorageReference!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = Storage.storage().reference()
        
        imagePicker.delegate = self
        
        displayUserPicture()
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage.maskInCircle(image: pickedImage, radius: 78)
            imageView.contentMode = .scaleAspectFit
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func displayUserPicture() {
        imageView.image = #imageLiteral(resourceName: "DefaultAvatar")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    
}
