//
//  SignUpViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    var nameTextField: UITextField!
    var emailTextField: UITextField!
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var signupButton: UIButton!
    var backToLoginButton: UIButton!
    
    let indent: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFields()
        setupButtons()
    }
    
    @objc func signupButtonTapped() {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        print("tapped")
        if name != "" && email != "" && username != "" && password != "" {
            print("passed")
            UserAuthHelper.createUser(email: email, password: password, withBlock: { () in
                FirebaseAPIClient.createNewUser(name: name, username: username, email: email)
                self.nameTextField.text = ""
                self.emailTextField.text = ""
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
                self.performSegue(withIdentifier: "toFeed", sender: self)
            })
        }
        
        // do something if any textfields are incomplete
    }
    
    @objc func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Creation functions
    
    func setupTextFields() {
        nameTextField = UITextField(frame: CGRect(x: indent, y: 100, width: view.frame.width - 2 * indent, height: 50))
        nameTextField.placeholder = "Full Name"
        nameTextField.borderStyle = .roundedRect
        view.addSubview(nameTextField)
        
        emailTextField = UITextField(frame: CGRect(x: indent, y: nameTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        view.addSubview(emailTextField)
        
        usernameTextField = UITextField(frame: CGRect(x: indent, y: emailTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        view.addSubview(usernameTextField)
        
        passwordTextField = UITextField(frame: CGRect(x: indent, y: usernameTextField.frame.maxY + 10, width: view.frame.width - 2 * indent, height: 50))
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        view.addSubview(passwordTextField)
    }
    
    func setupButtons() {
        signupButton = UIButton(frame: CGRect(x: indent, y: passwordTextField.frame.maxY + 20, width: view.frame.width - 2 * indent, height: 50))
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.backgroundColor = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
        signupButton.layer.cornerRadius = 5
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        view.addSubview(signupButton)
        
        backToLoginButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        backToLoginButton.setTitle("Sign In", for: .normal)
        backToLoginButton.setTitleColor(UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0), for: .normal)
        backToLoginButton.layer.borderColor = UIColor.gray.cgColor
        backToLoginButton.layer.borderWidth = 0.5
        backToLoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(backToLoginButton)
    }

}
