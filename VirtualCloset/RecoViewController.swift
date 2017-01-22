//
//  RecoViewController.swift
//  VirtualCloset
//
//  Created by Utkarsh Pandey on 1/20/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
import Clarifai

class RecoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicked = false
    var activityind = UIActivityIndicatorView()
    let setOfConcepts = ["shirt", "polo", "sweater", "jacket", "pants", "briefs"]
    var theConcept = ""
    var theImage: UIImage? = nil
    var containsConcepts = false
    
    @IBAction func logOutButton(_ sender: Any) {
        
        PFUser.logOut()
        performSegue(withIdentifier: "ShowLogin", sender: self)
    }
    
    @IBOutlet weak var shirtView: UIImageView!
    
    @IBAction func takePictureButton(_ sender: Any)
    {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated:true, completion: nil)
        
    }
    
    
    
    @IBAction func chooseImageButton(_ sender: Any) {
        
        print ("Point 43")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        print ("Point 48")
        self.present(imagePicker, animated:true, completion: nil)
        print ("Point 50")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            shirtView.image = image
            theImage = image
            imagePicked = true
            
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToClosetButton(_ sender: Any) {
        
        if !imagePicked {
            
            createAlert(title: "No image!", message: "Please take a picture of a clothing item or choose one from the photo library")
            
        }
        else {
            
            self.activityind = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            self.activityind.center = self.view.center
            self.activityind.hidesWhenStopped = true
            self.activityind.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.activityind.startAnimating()
            self.view.addSubview(self.activityind)
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            
            //--------------Using Clarifai to find concept-------------------//
            //--------------------------------------------------------------//
            print("line 83 \n")
            if let currImage = theImage{
                
                let app = ClarifaiApp(appID: "j39FbCuOGp8ET1BeFX-RHHWQPnQtANTVR-CfTBEX", appSecret: "PpZyoDvid6Mgxwx_aVNYRUphZtg9VRG2zZtmxwNV")
                
                //let i = UIImage(named: "IMG_3492.jpg")
                //let clarifaiImage = ClarifaiImage(url: "")
                
                let clarifaiImage = ClarifaiImage(image: currImage)
                print("line 93 \n")
                if let a = app {
                    a.getModelByName("general-v1.3", completion: { (model, error) in

                        print("line 97 \n")
                        if error != nil {
                            
                            print("Could recognize image!")
                            
                        } else {
                            
                            print("line 109 \n")
                            if let img = clarifaiImage {
                                model?.predict(on: [img], completion: { (outputs, error) in
                                        //c is array of ClarifyOutput with 1 ClarifyObject
                                        if let c = outputs {
                                            //d is an array of ClariyConcepts
                                            if let d = c[0].concepts {
                                                //val is a concept
                                                var ii = 0
                                                for concept in d{
                                                    
                                                    if self.setOfConcepts.contains(concept.conceptName!) && ii == 0{
                                                        
                                                        self.theConcept = concept.conceptName!
                                                        /*
                                                        if let x = d as? NSDictionary{
                                                            if ll = x["sweater"]{
                                                            
                                                            }
                                                            print("Sweater: \(x["sweater"])")
                                                        }
 */
                                                        
                                                        print("the concept: \(self.theConcept) :\(concept.score)")
                                                        
                                                        // ----------Start sending to server ----------------//
                                                        
                                                        self.sendToParse()
                                                        
                                                        //------------Finished sending to server ------------//
                                                        
                                                        self.containsConcepts = true
                                                        //break
                                                        ii += 1
                                                    }
                                                    print ("output: \(concept.conceptName!) :\(concept.score)")
                                                    
                                                }
                                                if self.activityind.isAnimating{
                                                    
                                                    DispatchQueue.main.sync(){
                                                    
                                                        print("it's animating")
                                                        self.activityind.stopAnimating()
                                                        UIApplication.shared.endIgnoringInteractionEvents()
                                                    }
                                                    

                                                }
                                                if self.containsConcepts{
                                                    self.containsConcepts = false
                                                } else {
                                                    self.createAlert(title: "Unable to recognize the image!", message: "Please try a better image")
                                                }
                                            }
                                        }
                                })
                            }
                        }
                    })
                } else {
                    
                    print ("Model could not be returned")
                }
                
            }
            
        }
        /*
        if activityind.isAnimating{
             print("it's animating 2")
        
             activityind.stopAnimating()
             UIApplication.shared.endIgnoringInteractionEvents()
        }
         */
        print("line 190 \n")
        
        
    }
    func sendToParse(){
        
        // Images class with objectId, concept, UserId, Image
        
        let imageClass = PFObject(className: "Images")
        imageClass["concept"] = theConcept
        imageClass["UserId"] = PFUser.current()?.objectId!
        
        print("line 180")
        let imageData = UIImageJPEGRepresentation(theImage!, 0.5)
        let imageFile = PFFile(name: "image.jpg", data: imageData!)
        imageClass["imageFile"] = imageFile
        print("line 141 \n")
        
        imageClass.saveInBackground { (success, error) in
            
            if self.activityind.isAnimating{
                
                DispatchQueue.main.sync(){
                    
                    print("it's animating")
                    self.activityind.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                
                
            }
            print("line 145 \n")
            if error != nil {
                
                self.createAlert(title: "Oops! Something went wrong.", message: "Unable to add image. Please try again later.")
                
            } else {
                print("adding to closet")
                self.createAlert(title: "Success!", message: "Your \(self.theConcept) has been added to your closet!")
                self.shirtView.image = UIImage(named: "shirt icon.png")
                self.theImage = nil // Resetting theImage
                self.theConcept = "" // Resetting theConcept
                self.imagePicked = false
                
            }
            
        }
        
    }
    func createAlert(title: String, message :String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
