//
//  RegisterViewController.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/13/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit



class RegisterViewController: UIViewController {
    @IBOutlet var customerFTSegmentedControl: UISegmentedControl!

    @IBOutlet var topStackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var nameTextField: FTTextField!
    @IBOutlet var uploadImageView: UIImageView!
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var twitterLabel: UILabel!
    @IBOutlet var descriptionTextView: FTTextView!
    @IBOutlet var categoryTextField: FTTextField!
    @IBOutlet var passwordTextField: FTTextField!
    @IBOutlet var emailTextField: FTTextField!
    @IBOutlet var twitterTextField: FTTextField!
    
    var screenSize: CGRect = UIScreen.main.bounds
    
    @IBAction func onCustomerFTSegmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            twitterLabel.isHidden = true
            twitterTextField.isHidden = true
            categoryLabel.isHidden = true
            categoryTextField.isHidden = true
            descriptionLabel.isHidden = true
            descriptionTextView.isHidden = true
            
        } else if sender.selectedSegmentIndex == 1 {
            twitterLabel.isHidden = false
            twitterTextField.isHidden = false
            categoryLabel.isHidden = false
            categoryTextField.isHidden = false
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.orientation.isLandscape {
            topStackViewWidthConstraint.constant = screenSize.width/2
        } else {
        topStackViewWidthConstraint.constant = screenSize.width - 10
        }
        twitterLabel.isHidden = true
        twitterTextField.isHidden = true
        categoryLabel.isHidden = true
        categoryTextField.isHidden = true
        descriptionLabel.isHidden = true
        descriptionTextView.isHidden = true

        // Do any additional setup after loading the view.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let point = CGPoint(x: 0, y: 0)
        screenSize = CGRect(origin: point, size: size)
        if UIDevice.current.orientation.isLandscape {
            topStackViewWidthConstraint.constant = screenSize.width/2
        } else {
             topStackViewWidthConstraint.constant = screenSize.width - 10
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
