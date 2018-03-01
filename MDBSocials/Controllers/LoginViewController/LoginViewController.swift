//
//  LoginViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var signupButton: UIButton!
    var imageView: UIImageView!
    var tap: UITapGestureRecognizer!
    
    let indent: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        setupTextFields()
        setupButtons()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "toFeed", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func loginButtonTapped() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email != "" && password != "" {
            UserAuthHelper.logIn(email: email, password: password, withBlock: { () in
                self.passwordTextField.text = ""
                self.dismissKeyboard()
                self.performSegue(withIdentifier: "toFeed", sender: self)
            })
        }
    }
    
    @objc func signupButtonTapped() {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    @objc func addGestureRecognizer() {
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        view.removeGestureRecognizer(tap)
    }

    // MARK: Creation functions
    
    func setupImageView() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: 200))
        imageView.image = UIImage(named: "mdb_nooutline")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
    
    func setupTextFields() {
        emailTextField = UITextField(frame: CGRect(x: indent, y: imageView.frame.maxY + 30, width: view.frame.width - 2 * indent, height: 50))
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = UITextContentType("")
        emailTextField.addTarget(self, action: #selector(addGestureRecognizer), for: .touchDown)
        view.addSubview(emailTextField)
        
        passwordTextField = UITextField(frame: CGRect(x: indent, y: emailTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.textContentType = UITextContentType("")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.addTarget(self, action: #selector(addGestureRecognizer), for: .touchDown)
        view.addSubview(passwordTextField)
    }
    
    func setupButtons() {
        loginButton = UIButton(frame: CGRect(x: indent, y: passwordTextField.frame.maxY + 20, width: view.frame.width - 2 * indent, height: 50))
        loginButton.backgroundColor = Constants.lightBlueColor
        loginButton.setTitle("Login", for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        signupButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        signupButton.layer.borderColor = UIColor.gray.cgColor
        signupButton.layer.borderWidth = 0.5
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        view.addSubview(signupButton)
    }

}

