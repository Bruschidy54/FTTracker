//
//  RegisterViewController.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/13/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit
import Firebase
import Photos

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var customerFTSegmentedControl: UISegmentedControl! {
        didSet {
            customerFTSegmentedControl.tintColor = .themeBlue
        }
    }
    @IBOutlet var topStackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var nameTextField: FTTextField!
    @IBOutlet var uploadImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var twitterLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var phoneTextField: FTTextField!
    @IBOutlet var descriptionTextView: FTTextView!
    @IBOutlet var categoryTextField: FTTextField!
    @IBOutlet var passwordTextField: FTTextField!
    @IBOutlet var emailTextField: FTTextField!
    @IBOutlet var twitterTextField: FTTextField!
    @IBOutlet var registerButton: CurvedButton!
  
    
    var screenSize: CGRect = UIScreen.main.bounds
    var userType: UserType = .Customer
    let imagePicker = UIImagePickerController()
    var profilePicture: UIImage?
    
    
    
    @IBAction func onCustomerFTSegmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userType = .Customer
            formatForms()
            
        } else if sender.selectedSegmentIndex == 1 {
            userType = .FoodTruck
            formatForms()
        }
    }
    
    @IBAction func onRegisterButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, let name = nameTextField.text, let password = passwordTextField.text else {
            createAlertController(withTitle: "Required Field Missing", andMessage: "Please provide a valid username, email, and password")
            return
        }
        
        guard password.count >= 6 else {
            createAlertController(withTitle: "Password Too Short", andMessage: "Please provide a password that is at least 6 characters")
            return
        }
        
        createNewUser(withEmail: email, andPassword: password, andName: name)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        imagePicker.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickPhoto(gestureRecognizer:)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(tap)
        
        formatScreenSize()
        
        twitterLabel.isHidden = true
        twitterTextField.isHidden = true
        categoryLabel.isHidden = true
        categoryTextField.isHidden = true
        descriptionLabel.isHidden = true
        descriptionTextView.isHidden = true
        phoneLabel.isHidden = true
        phoneTextField.isHidden = true


        // Do any additional setup after loading the view.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let point = CGPoint(x: 0, y: 0)
        screenSize = CGRect(origin: point, size: size)
        formatScreenSize()
    }
    
    func createNewUser(withEmail email: String, andPassword password: String, andName name: String) {
        print("email: \(email), password: \(password), name: \(name)")
        
        
        
        Auth.auth().createUser(withEmail: email, password: password, completion:  { (user, error) in
            if error != nil {
                print(error!)
                // TO DO: Throw signup error
            } else {
                
                
                
                
                UserDefaults.standard.set(user?.user.uid ?? "", forKey: "uid")
                self.uploadProfilePicture()
                let ref = Database.database().reference()
                switch self.userType {
                case .Customer:
                    let customerDict: [String : Any] = ["name" : name, "email" : email, "password" : password, "joinedDate": Date().timeIntervalSince1970, "uid" : UserDefaults.standard.value(forKey: "uid")]
                    ref.child("Customers").setValue([user?.user.uid ?? "" : customerDict])
                    
                case .FoodTruck:
                    let phone = self.phoneTextField.text ?? ""
                    let twitter = self.twitterTextField.text ?? ""
                    let category = self.categoryTextField.text ?? ""
                    let description = self.descriptionTextView.text ?? ""
                    guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
                    let foodTruckDict: [String : Any] = ["name" : name, "email" : email, "password" : password, "phone" : phone, "rating" : 0, "twitter" : twitter, "category" : category, "description" : description, "joinedDate" : Date().timeIntervalSince1970, "uid" : uid ]
                    ref.child("FoodTrucks").setValue([user?.user.uid ?? "": foodTruckDict])
                    break
                default:
                    break
                }
            }
        })
    } 
    
    func uploadProfilePicture() {
        // TO DO:
    }
    
    func formatScreenSize() {
        if UIDevice.current.orientation.isLandscape {
            topStackViewWidthConstraint.constant = screenSize.width/2 - 5
        } else {
            topStackViewWidthConstraint.constant = screenSize.width - 10
        }
    }
    
    func formatForms() {
        switch userType {
        case .Customer:
            self.twitterLabel.isHidden = true
            self.twitterTextField.isHidden = true
            self.categoryLabel.isHidden = true
            self.categoryTextField.isHidden = true
            self.descriptionLabel.isHidden = true
            self.descriptionTextView.isHidden = true
            self.phoneLabel.isHidden = true
            self.phoneTextField.isHidden = true
        case .FoodTruck:
            twitterLabel.isHidden = false
            twitterTextField.isHidden = false
            categoryLabel.isHidden = false
            categoryTextField.isHidden = false
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = false
            phoneLabel.isHidden = false
            phoneTextField.isHidden = false

        default:
            break
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func createAlertController(withTitle title: String, andMessage message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        // TO DO: Add stupid iPad popover controller action
        present(ac, animated: true, completion: nil)
    }
    
    @objc func pickPhoto(gestureRecognizer: UITapGestureRecognizer) {
        PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) in
            switch status {
            case .authorized:
            print("Authorized")
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
            break
            case .denied:
            print("Denied")
            break
            default:
            print("Default")
            break
        }
    })
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("Update profile picture")
            uploadImageView.contentMode = .scaleAspectFit
            uploadImageView.image = pickedImage
            profilePicture = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
  @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
