//
//  CreateEventModalView.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/20/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit

class CreateEventModalView: UIView {

    var cancelButton: UIButton!
    var nameTextView: UITextView!
    var descriptionTextView: UITextView!
    var eventImageView: UIImageView!
    var chooseImageButton: UIButton!
    let picker = UIImagePickerController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
//        layer.cornerRadius = 10
        
        setupTextFields()
        setupButtons()
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Creation functions
    
    func setupTextFields() {
        nameTextView = UITextView(frame: CGRect(x: 10, y: 50, width: frame.width - 20, height: 40))
        nameTextView.text = "Name of Event"
        nameTextView.isEditable = true
        nameTextView.textColor = .lightGray
        nameTextView.font = UIFont.systemFont(ofSize: 18)
        nameTextView.isScrollEnabled = false
        nameTextView.delegate = self
        addSubview(nameTextView)
        
        var line = UIView(frame: CGRect(x: 10, y: nameTextView.frame.maxY, width: frame.width - 20, height: 1))
        line.backgroundColor = .gray
        addSubview(line)
        
        descriptionTextView = UITextView(frame: CGRect(x: 10, y: line.frame.maxY, width: frame.width - 20, height: 200))
        descriptionTextView.text = "Description of Event"
        descriptionTextView.isEditable = true
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
        descriptionTextView.delegate = self
        addSubview(descriptionTextView)
        
        line = UIView(frame: CGRect(x: 10, y: descriptionTextView.frame.maxY, width: frame.width - 20, height: 1))
        line.backgroundColor = .gray
        addSubview(line)
    }
    
    func setupButtons() {
        cancelButton = UIButton(frame: CGRect(x: frame.width - 40, y: 10, width: 40, height: 40))
        let attrStr = NSAttributedString(string: "×", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40)])
        cancelButton.setAttributedTitle(attrStr, for: .normal)
        addSubview(cancelButton)
    }
    
    func setupImageView() {
        eventImageView = UIImageView(frame: CGRect(x: 10, y: descriptionTextView.frame.maxY + 10, width: frame.width - 20, height: frame.height - descriptionTextView.frame.maxY - 10))
        chooseImageButton = UIButton(frame: eventImageView.frame)
        chooseImageButton.setTitle("Choose event image", for: .normal)
        chooseImageButton.setTitleColor(UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0), for: .normal)
        addSubview(eventImageView)
        addSubview(chooseImageButton)
        bringSubview(toFront: chooseImageButton)
    }

}

extension CreateEventModalView: UITextViewDelegate {
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
