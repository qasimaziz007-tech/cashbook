//
//  LoginViewController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar on login screen
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Clear fields
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.Colors.background
        
        // Configure card view
        cardView.backgroundColor = Constants.Colors.cardBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        
        // Configure title
        titleLabel.text = Constants.appName
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = Constants.Colors.brand
        
        // Configure subtitle
        subtitleLabel.text = "Welcome to \(Constants.companyName)"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = Constants.Colors.textSecondary
        
        // Configure login button
        loginButton.backgroundColor = Constants.Colors.brand
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.shadowColor = Constants.Colors.brand.cgColor
        loginButton.layer.shadowOpacity = 0.3
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginButton.layer.shadowRadius = 4
        
        // Configure logo (placeholder)
        logoImageView.image = UIImage(systemName: "car.fill")
        logoImageView.tintColor = Constants.Colors.brand
        logoImageView.contentMode = .scaleAspectFit
    }
    
    private func setupTextFields() {
        // Configure text fields
        [usernameTextField, passwordTextField].forEach { textField in
            textField?.borderStyle = .none
            textField?.backgroundColor = UIColor.systemGray6
            textField?.layer.cornerRadius = 10
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.systemGray4.cgColor
            textField?.font = UIFont.systemFont(ofSize: 16)
            
            // Add padding
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField?.frame.height ?? 0))
            textField?.leftView = paddingView
            textField?.leftViewMode = .always
        }
        
        // Configure specific text field properties
        usernameTextField.placeholder = "Username"
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.returnKeyType = .next
        usernameTextField.delegate = self
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        
        // Add icons
        usernameTextField.leftView = createTextFieldIconView(systemName: "person.fill")
        passwordTextField.leftView = createTextFieldIconView(systemName: "lock.fill")
    }
    
    private func createTextFieldIconView(systemName: String) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let iconImageView = UIImageView(image: UIImage(systemName: systemName))
        iconImageView.tintColor = Constants.Colors.textSecondary
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.frame = CGRect(x: 12, y: 12, width: 16, height: 16)
        containerView.addSubview(iconImageView)
        return containerView
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        login()
    }
    
    private func login() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both username and password.")
            return
        }
        
        // Show loading state
        loginButton.isEnabled = false
        loginButton.setTitle("Logging in...", for: .normal)
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if UserManager.shared.login(username: username, password: password) {
                self?.navigateToMainApp()
            } else {
                self?.showLoginError()
            }
            
            // Reset button state
            self?.loginButton.isEnabled = true
            self?.loginButton.setTitle("Login", for: .normal)
        }
    }
    
    private func navigateToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.mainTabBarController) as! MainTabBarController
        
        // Get the scene delegate and update the root view controller
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = mainTabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    private func showLoginError() {
        // Add shake animation
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.6
        shake.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        cardView.layer.add(shake, forKey: "shake")
        
        showAlert(title: "Login Failed", message: "Invalid username or password. Please try again.")
        
        // Clear password field
        passwordTextField.text = ""
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Constants.Colors.brand.cgColor
        textField.layer.borderWidth = 2
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
    }
}