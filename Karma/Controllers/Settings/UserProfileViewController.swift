//
//  UserProfileViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 2/4/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseStorage

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let borderWidth = 2.0
    let borderColor = UIColor.black.cgColor
    
    let imagePicker = UIImagePickerController()
    var imageURL : URL!
    var storageRef : StorageReference!
    
    @IBOutlet var nameField : UITextField!
    @IBOutlet var numberField : UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        setFields()
    }
    
    private func setupView() {
        storageRef = Storage.storage().reference()
        activityIndicator.hidesWhenStopped = true
        imagePicker.delegate = self
    }
    
    private func setFields() {
        UserUtil.getCurrentProperty(key: "name") { name in
            self.nameField.text = name as? String ?? ""
        }
        
        UserUtil.getCurrentProperty(key: "phoneNumber") { number in
            self.numberField.text = number as? String ?? ""
        }
        
        UserUtil.getCurrentImageURL() { url in
            self.imageURL = url
            self.displayUserPicture()
        }
    }
    
    private func displayUserPicture() {
        let path = imageURL.path
        if path.hasPrefix("/userImages/"){
            ImageCache.default.retrieveImage(forKey: UserUtil.getCurrentId()!, options: nil) {
                image, cacheType in
                if let image = image {
                    self.imageView.image = image
                } else {
                    self.activityIndicator.startAnimating()
                    self.storageRef.child(path).getData(maxSize: INT64_MAX) {(data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage.init(data: data!)
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        } else {
            imageView.image = #imageLiteral(resourceName: "DefaultAvatar")
            UserUtil.setImageURL(photoURL: URL(string: "default")!)
        }
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImageToServer(image: pickedImage)
        } else { return }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImageToServer(image: UIImage) {
        UserUtil.getCurrentUserName() { userName in
            // Crop the image into a circle
            self.imageView.image = image.fixOrientation()
            let roundImage = self.makeRoundImg(img: self.imageView)
            self.imageView.image = roundImage
            self.saveImageToCache(image: roundImage)
            
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
                    UserUtil.setImageURL(photoURL: URL(string: "gs://karma-b3940.appspot.com/\(imagePath)")!)
                }
                
                print("User image has been uploaded to the server")
            }
        }
    }
    
    private func saveImageToCache(image: UIImage) {
        let id = UserUtil.getCurrentId()!
        ImageCache.default.removeImage(forKey: id)
        ImageCache.default.store(image, forKey: id)
        print("User image has been saved to cache")
    }
    
    // TODO: extract this out of this class
    func makeRoundImg(img: UIImageView) -> UIImage {
        let imgLayer = CALayer()
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 145, height: 145))
        imgLayer.frame = rect
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
