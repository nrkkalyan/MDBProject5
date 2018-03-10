//
//  CreateEventViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import PromiseKit

class CreateEventViewController: UIViewController {
    
    var cancelButton: UIButton!
    var nameTextView: UITextView!
    var locationTextView: UITextView!
    var descriptionTextView: UITextView!
    var eventImageView: UIImageView!
    var chooseImageButton: UIButton!
    let imagePicker = UIImagePickerController()
    var datePicker: UIDatePicker!
    var createButton: UIButton!
    var tap: UITapGestureRecognizer!
    
    var uid: String!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        setupButtons()
        setupImageView()
        setupDatePicker()
        
        imagePicker.delegate = self
        if let currUser = Auth.auth().currentUser {
            self.uid = currUser.uid
            firstly {
                return User.getCurrentUser(withId: uid)
            }.done { user in
                self.user = user
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideNBar"), object: nil)
    }
    
    func addGestureRecognizer() {
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        view.removeGestureRecognizer(tap)
    }
    
    @objc func cancelButtonTapped() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhideNBar"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func createButtonTapped() {
        let name = nameTextView.text ?? ""
        let description = descriptionTextView.text ?? ""
        let location = locationTextView.text ?? ""
        let imageData = UIImageJPEGRepresentation(eventImageView.image!, 0.5)
        let date = Utils.createDateString(date: datePicker.date)
        let time = Utils.createTimeString(date: datePicker.date)
        
        if name != "" && description != "" && location != "" {
            log.info("Creating new post.")
            let dateTime = "\(date)\n\(time)"
            FirebaseDBClient.createNewPost(name: name, description: description, location: location, date: dateTime, imageData: imageData!, host: user.name!, hostId: uid)
            log.info("New post created.")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhideNBar"), object: nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func chooseImage(sender: UIButton!) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Creation function
    
    func setupTextFields() {
        nameTextView = UITextView(frame: CGRect(x: 10, y: 50, width: view.frame.width - 20, height: 40))
        nameTextView.text = "Name of Event"
        nameTextView.isEditable = true
        nameTextView.textColor = .lightGray
        nameTextView.font = UIFont.systemFont(ofSize: 18)
        nameTextView.isScrollEnabled = false
        nameTextView.delegate = self
        nameTextView.autocorrectionType = .no
        nameTextView.autocapitalizationType = .words
        view.addSubview(nameTextView)
        
        var line = UIView(frame: CGRect(x: 10, y: nameTextView.frame.maxY, width: view.frame.width - 20, height: 1))
        line.backgroundColor = .gray
        view.addSubview(line)
        
        locationTextView = UITextView(frame: CGRect(x: 10, y: line.frame.maxY, width: view.frame.width - 20, height: 40))
        locationTextView.text = "Location of Event"
        locationTextView.isEditable = true
        locationTextView.textColor = .lightGray
        locationTextView.font = UIFont.systemFont(ofSize: 18)
        locationTextView.isScrollEnabled = false
        locationTextView.delegate = self
        locationTextView.autocorrectionType = .no
        locationTextView.autocapitalizationType = .words
        view.addSubview(locationTextView)
        
        line = UIView(frame: CGRect(x: 10, y: locationTextView.frame.maxY, width: view.frame.width - 20, height: 1))
        line.backgroundColor = .gray
        view.addSubview(line)
        
        descriptionTextView = UITextView(frame: CGRect(x: 10, y: line.frame.maxY, width: view.frame.width - 20, height: 120))
        descriptionTextView.text = "Description of Event"
        descriptionTextView.isEditable = true
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
        descriptionTextView.delegate = self
        descriptionTextView.autocorrectionType = .yes
        descriptionTextView.autocapitalizationType = .sentences
        view.addSubview(descriptionTextView)
    }
    
    func setupButtons() {
        cancelButton = UIButton(frame: CGRect(x: view.frame.width - 40, y: 10, width: 40, height: 40))
        let attrStr = NSAttributedString(string: "×", attributes: [NSAttributedStringKey.foregroundColor: Constants.lightBlueColor, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40)])
        cancelButton.setAttributedTitle(attrStr, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
//        createButton = UIButton(frame: CGRect(x: view.frame.width - 160, y: view.frame.height - 50, width: 150, height: 40))
        createButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        createButton.setTitle("Create Event", for: .normal)
        createButton.backgroundColor = Constants.lightBlueColor
//        createButton.layer.cornerRadius = 5
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.addSubview(createButton)
    }
    
    func setupImageView() {
        eventImageView = UIImageView(frame: CGRect(x: 10, y: descriptionTextView.frame.maxY + 10, width: view.frame.width - 20, height: 200))
        chooseImageButton = UIButton(frame: CGRect(x: view.frame.width/2 - 200, y: eventImageView.frame.maxY - eventImageView.frame.height/2 - 20, width: 400, height: 40))
        chooseImageButton.setTitle("Choose event image", for: .normal)
        chooseImageButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        view.addSubview(eventImageView)
        view.addSubview(chooseImageButton)
        view.bringSubview(toFront: chooseImageButton)
    }
    
    func setupDatePicker() {
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: eventImageView.frame.maxY + 10, width: view.frame.width, height: view.frame.height - eventImageView.frame.maxY - 60))
        datePicker.datePickerMode = .dateAndTime
        view.addSubview(datePicker)
    }
    
}

extension CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        chooseImageButton.setTitle("", for: .normal)
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        eventImageView.contentMode = .scaleAspectFit
        eventImageView.image = chosenImage
        picker.dismiss(animated:true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { () in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideNBar"), object: nil)
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { () in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideNBar"), object: nil)
        })
    }
}

extension CreateEventViewController: UITextViewDelegate {
    public func textViewDidBeginEditing (_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
        addGestureRecognizer()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            if textView == self.descriptionTextView {
                textView.text = "Description of Event"
            } else if textView == self.nameTextView {
                textView.text = "Name of Event"
            } else if textView == self.locationTextView {
                textView.text = "Location of Event"
            }
        }
    }
}
