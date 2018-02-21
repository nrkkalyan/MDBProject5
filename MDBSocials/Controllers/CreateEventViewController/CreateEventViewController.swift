//
//  CreateEventViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {
    
    var cancelButton: UIButton!
    var nameTextView: UITextView!
    var descriptionTextView: UITextView!
    var eventImageView: UIImageView!
    var chooseImageButton: UIButton!
    let imagePicker = UIImagePickerController()
    var datePicker: UIDatePicker!
    var createButton: UIButton!
    
    var user: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        setupButtons()
        setupImageView()
        setupDatePicker()
        imagePicker.delegate = self
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func createButtonTapped() {
        let name = nameTextView.text ?? ""
        let description = descriptionTextView.text ?? ""
        let image = eventImageView.image ?? UIImage()
        let date = datePicker.date
        
        if name != "" && description != "" {
            FirebaseAPIClient.createNewPost(name: name, description: description, date: date, image: image, host: user)
            dismiss(animated: true, completion: nil)
        }
        
        // do something if any textfields are incomplete
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
        view.addSubview(nameTextView)
        
        let line = UIView(frame: CGRect(x: 10, y: nameTextView.frame.maxY, width: view.frame.width - 20, height: 1))
        line.backgroundColor = .gray
        view.addSubview(line)
        
        descriptionTextView = UITextView(frame: CGRect(x: 10, y: line.frame.maxY, width: view.frame.width - 20, height: 150))
        descriptionTextView.text = "Description of Event"
        descriptionTextView.isEditable = true
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
    }
    
    func setupButtons() {
        cancelButton = UIButton(frame: CGRect(x: view.frame.width - 40, y: 10, width: 40, height: 40))
        let attrStr = NSAttributedString(string: "×", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40)])
        cancelButton.setAttributedTitle(attrStr, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        createButton = UIButton(frame: CGRect(x: view.frame.width - 160, y: view.frame.height - 50, width: 150, height: 40))
        createButton.setTitle("Create Event", for: .normal)
        createButton.backgroundColor = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
        createButton.layer.cornerRadius = 5
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.addSubview(createButton)
    }
    
    func setupImageView() {
        eventImageView = UIImageView(frame: CGRect(x: 10, y: descriptionTextView.frame.maxY + 10, width: view.frame.width - 20, height: 200))
        chooseImageButton = UIButton(frame: eventImageView.frame)
        chooseImageButton.setTitle("Choose event image", for: .normal)
        chooseImageButton.setTitleColor(UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0), for: .normal)
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
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateEventViewController: UITextViewDelegate {
    public func textViewDidBeginEditing (_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            if textView == self.descriptionTextView {
                textView.text = "Description of Event"
            } else if textView == self.nameTextView {
                textView.text = "Name of Event"
            }
        }
    }
}
