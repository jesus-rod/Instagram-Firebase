//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Jesus Adolfo on 4/26/17.
//  Copyright © 2017 jesus. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "updateFeed")
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
         view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
    
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func handleShare() {
        print("Share PHoto")
        
        guard let caption = textView.text, caption.characters.count > 0  else { return }
        
        guard let image = selectedImage else { return }
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        FIRStorage.storage().reference().child("posts").child(filename).put(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                print("failed to upload post image:", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded post image:", imageUrl)
            
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        
        guard let postImage = selectedImage else { return }
        
        guard let caption = textView.text else { return }
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let userPostRef = FIRDatabase.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageUrl": imageUrl,
                      "caption": caption,
                      "imageWidth": postImage.size.width,
                      "imageHeight": postImage.size.height,
                      "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("failed to save post to db:", err)
                return
            }
            
            print("Success saving post to DB", ref)
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
 
