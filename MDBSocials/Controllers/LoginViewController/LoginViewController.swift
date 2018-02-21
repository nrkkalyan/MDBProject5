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
    
    let indent: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        setupTextFields()
        setupButtons()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "toFeed", sender: self)
        }
    }
    
    @objc func loginButtonTapped() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email != "" && password != "" {
            UserAuthHelper.logIn(email: email, password: password, withBlock: { () in
                self.performSegue(withIdentifier: "toFeed", sender: self)
            })
        }
        
        // do something if any textfields are empty
    }
    
    @objc func signupButtonTapped() {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }

    // MARK: Creation functions
    
    func setupTextFields() {
        emailTextField = UITextField(frame: CGRect(x: indent, y: 200, width: view.frame.width - 2 * indent, height: 50))
        emailTextField.placeholder = "Username"
        emailTextField.borderStyle = .roundedRect
        view.addSubview(emailTextField)
        
        passwordTextField = UITextField(frame: CGRect(x: indent, y: emailTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        view.addSubview(passwordTextField)
    }
    
    func setupButtons() {
        loginButton = UIButton(frame: CGRect(x: indent, y: passwordTextField.frame.maxY + 20, width: view.frame.width - 2 * indent, height: 50))
        loginButton.backgroundColor = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
        loginButton.setTitle("Login", for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        signupButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.setTitleColor(UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0), for: .normal)
        signupButton.layer.borderColor = UIColor.gray.cgColor
        signupButton.layer.borderWidth = 0.5
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        view.addSubview(signupButton)
    }

}

