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
    
    @IBOutlet var customerFTSegmentedControl: UISegmentedControl!
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
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion:  { (user, error) in
            if error != nil {
                print(error!)
                // TO DO: Throw signup error
            } else {
               UserDefaults.standard.set(user!.uid, forKey: "uid")
                self.uploadProfilePicture()
                let ref = FIRDatabase.database().reference()
                switch self.userType {
                case .Customer:
                    let customerDict: [String : Any?] = ["name" : name, "email" : email, "password" : password, "joinedDate": Date().timeIntervalSince1970, "uid" : UserDefaults.standard.value(forKey: "uid")]
                    ref.child("Customers").setValue([user!.uid : customerDict])
                    
                case .FoodTruck:
                    let phone = self.phoneTextField.text ?? ""
                    let twitter = self.twitterTextField.text ?? ""
                    let category = self.categoryTextField.text ?? ""
                    let description = self.descriptionTextView.text ?? ""
                    guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
                    let foodTruckDict: [String : Any] = ["name" : name, "email" : email, "password" : password, "phone" : phone, "rating" : 0, "twitter" : twitter, "category" : category, "description" : description, "joinedDate" : Date().timeIntervalSince1970, "uid" : uid ]
                    ref.child("FoodTrucks").setValue([user!.uid : foodTruckDict])
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
            UIView.animate(withDuration: 0.3 , animations: {
                self.twitterLabel.alpha = 0
                self.twitterTextField.alpha = 0
                self.categoryLabel.alpha = 0
                self.categoryTextField.alpha = 0
                self.descriptionLabel.alpha = 0
                self.descriptionTextView.alpha = 0
                self.phoneLabel.alpha = 0
                self.phoneTextField.alpha = 0
            }) { (finished) in
            self.twitterLabel.isHidden = finished
            self.twitterTextField.isHidden = finished
            self.categoryLabel.isHidden = finished
            self.categoryTextField.isHidden = finished
            self.descriptionLabel.isHidden = finished
            self.descriptionTextView.isHidden = finished
            self.phoneLabel.isHidden = finished
            self.phoneTextField.isHidden = finished
            }
        case .FoodTruck:
            twitterLabel.alpha = 0
            twitterTextField.alpha = 0
            categoryLabel.alpha = 0
            categoryTextField.alpha = 0
            descriptionLabel.alpha = 0
            descriptionTextView.alpha = 0
            phoneLabel.alpha = 0
            phoneTextField.alpha = 0
            twitterLabel.isHidden = false
            twitterTextField.isHidden = false
            categoryLabel.isHidden = false
            categoryTextField.isHidden = false
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = false
            phoneLabel.isHidden = false
            phoneTextField.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.twitterLabel.alpha = 1
                self.twitterTextField.alpha = 1
                self.categoryLabel.alpha = 1
                self.categoryTextField.alpha = 1
                self.descriptionLabel.alpha = 1
                self.descriptionTextView.alpha = 1
                self.phoneLabel.alpha = 1
                self.phoneTextField.alpha = 1
            }

        default:
            break
        }
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
