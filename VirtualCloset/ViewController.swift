/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import Clarifai

class ViewController: UIViewController, UITextFieldDelegate {
    var activityIndicator = UIActivityIndicatorView()
    var logInMode = true
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var changeInfoLabel: UILabel!
    
    @IBOutlet weak var submitButtonLabel: UIButton!
    @IBOutlet weak var changeModeButtonLabel: UIButton!
    
    @IBAction func submitButton(_ sender: Any) {
        
        if usernameField.text == "" || passwordField.text == "" {
            
            createAlert(title: "Something is missing!", message: "Please enter a username and password")
            return
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if logInMode {
                // Logging in
                
                PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!, block: { (user, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if error != nil {
                        
                        var displayErrorMessage = "Unable to log in. Please try later."
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String {
                            
                            displayErrorMessage = errorMessage
                        }
                        self.createAlert(title: "Error in form", message: displayErrorMessage)
                        
                    } else {
                    
                        print ("Logged In")
                        self.performSegue(withIdentifier: "ShowReco", sender: self)
                        
                    }
                })
            } else { // Signing Up
            
                let currUser = PFUser()
                currUser.username = usernameField.text
                currUser.password = passwordField.text
                
                currUser.signUpInBackground(block: { (success, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        
                        var displayErrorMessage = "Unable to sign up. Please try later."
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String {
                            
                            displayErrorMessage = errorMessage
                        }
                        self.createAlert(title: "Error in form", message: displayErrorMessage)
                    } else {
                        
                        print ("Signed Up")
                        self.performSegue(withIdentifier: "ShowReco", sender: self)
                        
                    }
                })
            }
        }
    }

    @IBAction func changeModeButton(_ sender: Any) {
    
        if logInMode{
        
            logInMode = false
            changeInfoLabel.text = "Already have an account?"
            changeModeButtonLabel.setTitle("Log In", for: [])
            submitButtonLabel.setTitle("Sign Up", for: [])
        } else {
            
            logInMode = true
            changeInfoLabel.text = "Don't have an account?"
            changeModeButtonLabel.setTitle("Sign Up", for: [])
            submitButtonLabel.setTitle("Log In", for: [])
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func createAlert(title: String, message :String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
            
            print("PF is not nil")
            performSegue(withIdentifier: "ShowReco", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
