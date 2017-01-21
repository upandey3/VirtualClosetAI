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
    //let theImage: UIImage? = nil
    
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
            imagePicked = true
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToClosetButton(_ sender: Any) {
        
        if !imagePicked {
            
            createAlert(title: "No image!", message: "Please take a picture of a clothing item or choose one from the photo library")
            
        }
        else {
            activityind = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityind.center = self.view.center
            activityind.hidesWhenStopped = true
            activityind.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityind.startAnimating()
            view.addSubview(activityind)
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            //--------------Using Clarifai to find concept-------------------//
            //--------------------------------------------------------------//
            print("line 83 \n")
            if let currImage = shirtView.image{
                
                let app = ClarifaiApp(appID: "j39FbCuOGp8ET1BeFX-RHHWQPnQtANTVR-CfTBEX", appSecret: "PpZyoDvid6Mgxwx_aVNYRUphZtg9VRG2zZtmxwNV")
                //let i = UIImage(named: "IMG_3492.jpg")
                //let clarifaiImage = ClarifaiImage(image: i)//currImage)
                let clarifaiImage = ClarifaiImage(url: "http://ec2-54-186-136-62.us-west-2.compute.amazonaws.com/parse/files/cd99a626499d05f54cf13158d8da6b4d8bb23ae6/e5eddd4d0d987db833c242315d5cf96c_image.jpg")
                
                print("line 89 \n")
                if let a = app {
                    a.getModelByName("general-v1.3", completion: { (model, error) in
                        
                                        print("line 93 \n")
                        if error != nil {
                            
                            print("Could recognize image!")
                            
                        } else {
                            
                                            print("line 100 \n")
                            if let img = clarifaiImage {
                                model?.predict(on: [img], completion: { (outputs, error) in
                                    //c is array of ClarifyOutput with 1 ClarifyObject
                                    if let c = outputs {
                                        //d is an array of ClariyConcepts
                                        if let d = c[0].concepts {
                                            //val is a concept
                                            print("line 108 \n")
                                            for concept in d{
                                                
                                                if self.setOfConcepts.contains(concept.conceptName!){
                                                    
                                                    self.theConcept = concept.conceptName!
                                                    print("the concept: \(concept.conceptName!) :\(concept.score)")
                                                    break
                                                }
                                                print ("output: \(concept.conceptName!) :\(concept.score)")
                                                
                                            }
                                        }
                                    }
                                })
                                
                            } else {
                                
                                print ("Image is not valid")
                                
                            }
                        }
                        
                    })
                } else {
                    
                    print ("Model could not be returned")
                }

            }
            print("line 137 \n")

            //--------------------Found concept ----------------------------//
            //--------------------------------------------------------------//
            
            // Images class with objectId, concept, UserId, Image
            let imageClass = PFObject(className: "Images")
            
            imageClass["concept"] = theConcept
                
            imageClass["UserId"] = PFUser.current()?.objectId!
            
            let imageData = UIImageJPEGRepresentation(shirtView.image!, 0.5) //UIImagePNGRepresentation(imageToPost.image!)
            
            let imageFile = PFFile(name: "image.jpg", data: imageData!)
            
            imageClass["imageFile"] = imageFile
            
            imageClass.saveInBackground { (success, error) in
                
                self.activityind.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if error != nil {
                    
                    self.createAlert(title: "Oops! Something went wrong.", message: "Unable to add image. Please try again later.")
                    
                } else {
                    
                    self.createAlert(title: "Success!", message: "The clothing item(\(self.theConcept))) has been added to your closet")
                    self.shirtView.image = UIImage(named: "shirt icon.png")
                    
                    self.imagePicked = false
                    
                }
                
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
