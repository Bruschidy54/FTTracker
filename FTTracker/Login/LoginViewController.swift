//
//  LoginViewController.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/12/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: FTTextField!
    @IBOutlet var passwordTextField: FTTextField!
    
    @IBAction func onRegisterButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "RegisterSegue", sender: self)
    }
    
    @IBAction func onLogInButtonTapped(_ sender: Any) {
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
    }
        loginUser(withEmail: email, andPassword: password)
    }
    
    @IBAction func onGuestButtonTapped(_ sender: Any) {
        Auth.auth().signInAnonymously(completion: {(user, error) in
            if error != nil {
                //Tells the user that there is an error and then gets firebase to tell them the error
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                print("Guest login successful!")
                
                self.performSegue(withIdentifier: "GuestSegue", sender: self)
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround() 

    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if UserDefaults.standard.value(forKey: "uid") != nil && !FIRAuth.auth()?.currentUser?.isAnonymous {
//            self.performSegue(withIdentifier: "LogInSegue", sender: self)
//        }
//    }
    
    func loginUser(withEmail email: String, andPassword password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                //Tells the user that there is an error and then gets firebase to tell them the error
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                print("Login successful!")
                
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "LogInSegue", sender: self)
            }
        })
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - UITextViewDelegate Methods
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.dismissKeyboard()
            return false
        } else {
            return true
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If no major differences, eliminate GuestSegue. If no info is passed to TabBarController, then erase prepareForSegue
        if segue.identifier == "LogInSegue" {
            print("Performing LogInSegue")
        } else if segue.identifier == "GuestSegue" {
            print("Performing GuestSegue")
        }
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
