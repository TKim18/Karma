//
//  UserProfileViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 2/4/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import Kingfisher

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // imageView.image = getUserProfile()
        displayUserPicture()
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImageToServer(image: pickedImage)
            saveImageToCache(image: pickedImage)
            imageView.image = pickedImage.maskInCircle(image: pickedImage, radius: 78)
            imageView.contentMode = .scaleAspectFit
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func saveImageToCache (image: UIImage) {
        let id = User.getCurrentUserId()
        ImageCache.default.store(image, forKey: id as String)
    }
    
    private func displayUserPicture() {
        let imagePath = (User.getCurrentUserProperty(key: "imagePath") as! String)
        if (imagePath == "default") {
            imageView.image = UIImage(named: "DefaultAvatar")!
            return
        }
        // Attempt to retrieve image from cache
        ImageCache.default.retrieveImage(forKey: User.getCurrentUserId(), options: nil) {
            image, cacheType in
            if let image = image {
                self.imageView.image = image
            } else {
                print("That image does not exist in cache, pulling from server")
                let url = URL(string: imagePath)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        let onlineImage = UIImage(data: data!)
                        self.saveImageToCache(image: onlineImage!)
                        self.imageView.image = onlineImage
                    }
                }
            }
        }
    }
    
    private func uploadImageToServer(image: UIImage) {
        let backendless = Backendless.sharedInstance()
        
        let imageData: Data = image.jpeg(.low)!
        let path = "userImages/" + String(User.getCurrentUser().email) + ".png"
        let currentUser = backendless!.userService.currentUser
        
        backendless!.file.saveFile(
            path,
            content: imageData,
            overwriteIfExist: true,
            response: {
                (savedFile: BackendlessFile?) -> Void in
                // Upload the current user's image path attribute
                let imagePath = "https://api.backendless.com/4E2E1A3D-FFCD-0343-FF47-1C589EC9B700/FA7EA74D-684C-9B00-FF57-36FE9F512200/files/userImages/" + String(currentUser!.email) + ".png"
                currentUser!.updateProperties(["imagePath" : imagePath])
                backendless!.userService.update(
                    currentUser,
                    response: {
                        (updatedUser: BackendlessUser?) -> Void in
                        print ("User image has been updated")
                },
                    error: {
                        (fault : Fault?) -> () in
                        print("Server reported an error: \(String(describing: fault))")
                })
                print("New image saved to server")
            },
            error: {
                (fault: Fault?) -> Void in
                print("Server reported an error")
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    
}
