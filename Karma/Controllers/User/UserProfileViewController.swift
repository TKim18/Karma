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

    let borderWidth = 1.0
    let borderColor = UIColor.black.cgColor
    
    let imagePicker = UIImagePickerController()
    var imageURL : URL!
    var storageRef : StorageReference!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        displayUserPicture()
    }
    
    private func setupView() {
        storageRef = Storage.storage().reference()
        imageURL = UserUtil.getCurrentImagePath()
        imagePicker.delegate = self
    }
    
    private func displayUserPicture() {
        if imageURL.path == "default" {
            imageView.image = #imageLiteral(resourceName: "DefaultAvatar")
        } else {
            self.storageRef.child(imageURL.path).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage.init(data: data!)
                }
            }
        }
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UserUtil.getCurrentUserName() { userName in
                // Crop the image into a circle
                self.imageView.image = pickedImage
                self.imageView.image = self.makeRoundImg(img: self.imageView)
                
                // Convert the image into Data type
                let imageData = UIImagePNGRepresentation(self.imageView.image!)
                let imagePath = "userImages/\(userName).png"
                let metaData = StorageMetadata()
                metaData.contentType = "image/png"

                // Upload the image to Firebase storage
                self.storageRef.child(imagePath).putData(imageData!, metadata: metaData) {
                    (metadata, error) in
                    if let error = error {
                        print (error.localizedDescription)
                    }
                    
                    // Update the user photo if it is still on default
                    if self.imageURL == URL(string: "default") {
                        UserUtil.setImagePath(photoURL: URL(string: "gs://karma-b3940.appspot.com/\(imagePath)")!)
                    }
                }
            }
        } else { return }
        
        dismiss(animated: true, completion: nil)
    }
    
    func makeRoundImg(img: UIImageView) -> UIImage {
        let imgLayer = CALayer()
        imgLayer.frame = img.bounds
        imgLayer.contents = img.image?.cgImage;
        imgLayer.masksToBounds = true;
        
        imgLayer.cornerRadius = img.frame.size.width/2
        UIGraphicsBeginImageContext(img.bounds.size)
        imgLayer.render(in: UIGraphicsGetCurrentContext()!)
        imgLayer.borderWidth = CGFloat(self.borderWidth)
        imgLayer.borderColor = self.borderColor
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!;
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    
}
