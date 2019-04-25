//
//  Viewcontroller2.swift
//  MobileGame
//
//  Created by Keith-William Cotnoir on 2019-04-25.
//  Copyright © 2019 Keith-William Cotnoir. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class Viewcontroller2: UIViewController {
    

    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func action(_ sender: UIButton)
    {
        if emailText.text != "" && passwordText.text != ""
        {
            if segmentControl.selectedSegmentIndex == 0
            {
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil
                    {
                        //sign in worked
                        self.performSegue(withIdentifier: "Segway", sender: self)
                        print("Success")
                    }
                    else
                    {
                        if let myError = error?.localizedDescription
                        {
                            print(myError)
                        }
                        else
                        {
                            print("ERROR")
                        }
                    }
                })
            }
            else //sign up the home boy
            {
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil
                    {
                         self.performSegue(withIdentifier: "Segway", sender: self)
                        print("Success")
                    }
                    else
                    {
                        if let myError = error?.localizedDescription
                        {
                            print(myError)
                        }
                        else
                        {
                            print("ERROR")
                        }
                    }
                })
            }
        }
    }
}
