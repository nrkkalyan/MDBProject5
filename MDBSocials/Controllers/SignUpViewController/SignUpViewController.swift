//
//  SignUpViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import PromiseKit

class SignUpViewController: UIViewController {

    var profileImageView: UIImageView!
    var profileImageButton: UIButton!
    var imagePicker = UIImagePickerController()
    var nameTextField: UITextField!
    var emailTextField: UITextField!
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var signupButton: UIButton!
    var backToLoginButton: UIButton!
    var tap: UITapGestureRecognizer!
    
    let indent: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageView()
        setupTextFields()
        setupButtons()
        
        imagePicker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: "showAlert"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func showAlert(not: Notification) {
        let content = not.userInfo as! [String:Any]
        let title = content["title"] as! String
        let message = content["message"] as! String
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func signupButtonTapped() {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if let image = profileImageView.image {
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            if name != "" && email != "" && username != "" && password != "" {
                firstly {
                    return UserAuthHelper.createUser(email: email, password: password)
                }.done { uid in
                    RESTAPIClient.createNewUser(uid: uid, name: name, username: username, email: email, imageData: imageData!)
                    self.nameTextField.text = ""
                    self.emailTextField.text = ""
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.profileImageView.image = nil
                    self.profileImageButton.setTitle("Choose profile image", for: .normal)
                    self.performSegue(withIdentifier: "toFeed", sender: self)
                }
            } else {
                log.warning("One of the textfields is empty.")
                
                let alert = UIAlertController(title: "Invalid Input", message: "Make sure to fill in all textfields!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } else {
            log.warning("User did not upload a profile picture.")
            
            let alert = UIAlertController(title: "Profile Picture", message: "Upload a profile picture!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addGestureRecognizer() {
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        view.removeGestureRecognizer(tap)
    }
    
    @objc func chooseImage(sender: UIButton!) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Creation functions
    
    func setupImageView() {
        profileImageView = UIImageView(frame: CGRect(x: view.frame.width/2 - 50, y: 30, width: 100, height: 100))
        profileImageButton = UIButton(frame: CGRect(x: view.frame.width/2 - 100, y: profileImageView.frame.maxY - profileImageView.frame.height/2 - 25, width: 200, height: 50))
        profileImageButton.setTitle("Choose profile image", for: .normal)
        profileImageButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        profileImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        view.addSubview(profileImageView)
        view.addSubview(profileImageButton)
        view.bringSubview(toFront: profileImageButton)
    }
    
    func setupTextFields() {
        nameTextField = UITextField(frame: CGRect(x: indent, y: profileImageView.frame.maxY + 15, width: view.frame.width - 2 * indent, height: 50))
        nameTextField.placeholder = "Full Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocorrectionType = .no
        nameTextField.autocapitalizationType = .words
        nameTextField.addTarget(self, action: #selector(addGestureRecognizer), for: .touchDown)
        view.addSubview(nameTextField)
        
        emailTextField = UITextField(frame: CGRect(x: indent, y: nameTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.addTarget(self, action: #selector(addGestureRecognizer), for: .touchDown)
        view.addSubview(emailTextField)
        
        usernameTextField = UITextField(frame: CGRect(x: indent, y: emailTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        usernameTextField.textContentType = UITextContentType("")
        usernameTextField.addTarget(self, action: #selector(addGestureRecognizer), for: .touchDown)
        view.addSubview(usernameTextField)
        
        passwordTextField = UITextField(frame: CGRect(x: indent, y: usernameTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.textContentType = UITextContentType("")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.addTarget(self, action: #selector(addGestureRecognizer), for: .touchDown)
        view.addSubview(passwordTextField)
    }
    
    func setupButtons() {
        signupButton = UIButton(frame: CGRect(x: indent, y: passwordTextField.frame.maxY + 20, width: view.frame.width - 2 * indent, height: 50))
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.backgroundColor = Constants.lightBlueColor
        signupButton.layer.cornerRadius = 5
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        view.addSubview(signupButton)
        
        backToLoginButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        backToLoginButton.setTitle("Sign In", for: .normal)
        backToLoginButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        backToLoginButton.layer.borderColor = UIColor.gray.cgColor
        backToLoginButton.layer.borderWidth = 0.5
        backToLoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(backToLoginButton)
    }

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profileImageButton.setTitle("", for: .normal)
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
