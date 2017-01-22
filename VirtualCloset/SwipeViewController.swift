//
//  SwipeViewController.swift
//  VirtualCloset
//
//  Created by Utkarsh Pandey on 1/21/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var imageFrame: UICollectionView!
    
    var concepts: [String] = []
    var array = [UIImage]() // array of 3
    var wool : [UIImage] = []
    var top : [UIImage] = []
    var bottom : [UIImage] = []
    var arrayTop : [UIImage] = []
    var arrayBottom : [UIImage] = []
    var arrayWool : [UIImage] = []
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let city = City
        if City == ""{
            City = "Chicago"
        }
        
        let temperature = getTemperature(city: city)
        
        let object = Outfits()
        concepts = object.getConcepts(input_temperature : temperature)
        print("Concepts are \(self.concepts)")
        
        let mainFrameGesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        
        imageFrame.isUserInteractionEnabled = true
        imageFrame.addGestureRecognizer(mainFrameGesture)
        
        pickOutfits()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SwipeCollectionViewCell
        
        cell.imageCell.image = array[indexPath.row]
        
        return cell
        
    }
    func pickOutfits()
    {
        //     let semaphoretwo = DispatchSemaphore(value: 0)
        index = 0
        self.arrayBottom.removeAll()
        self.arrayTop.removeAll()
        self.arrayWool.removeAll()
        self.array.removeAll()
        
        print("Reached 71")
        let query = PFQuery(className: "Images")
        print("Reached 73")
        
        
        query.whereKey("UserId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print("Reached 79")
                
                print("\nUnable to get users \(error!)")
            } else {
                
                print("Reached 83")
                
                if let images = objects{
                    
                    if images.count > 0 {
                        
                        print("Reached 104")
                        for image in images{
                            
                            if ((image["concept"] as? String) == self.concepts[0]) {
                                
                                print("Match")
                                print(image["imageFile"])
                                if let imageFile = image["imageFile"] as? PFFile {
                                    print("entered imageFile block")
                                    let datao = try! imageFile.getData()
                                    
                                    print("reached 118")
                                    if let pic = UIImage(data: datao){
                                        
                                        self.top.append(pic)
                                        print("Success at top")
                                    }else{
                                        print("Not appending")
                                    }
                                    
                                } else {
                                    
                                    print("PFFIle not converting")
                                }
                            } else if (image["concept"] as? String) == self.concepts[1]{
                                
                                if let imageFile = image["imageFile"] as? PFFile {
                                    
                                    
                                    let datao = try! imageFile.getData()
                                    if let pic = UIImage(data: datao){
                                        
                                        self.bottom.append(pic)
                                        print("Success at wool")
                                    }else{
                                        print("Not appending")
                                    }
                                    
                                } else {
                                    
                                    print("PFFIle not converting")
                                }
                            } else if (image["concept"] as? String) == self.concepts[2]{
                                
                                if let imageFile = image["imageFile"] as? PFFile {
                                    let datao = try! imageFile.getData()
                                    if let pic = UIImage(data: datao){
                                        
                                        self.wool.append(pic)
                                        print("Success at wool")
                                    }else{
                                        print("Not appending")
                                    }
                                    
                                } else {
                                    
                                    print("PFFile not converting")
                                }
                            }
                        }
                        print("Reached 158")
                        print("\(self.top.count)")
                        print("\(self.bottom.count)")
                        print("\(self.wool.count)")
                        let maxCount = max(self.bottom.count, self.wool.count, self.top.count)
                        print("Reached 158")
                        print("Max count is \(maxCount)")
                        var i = 0
                        while i < maxCount{
                            
                            print("\(i)")
                            
                            if self.top.count > 0 {
                                self.arrayTop.append(self.top[i % (self.top.count)])
                            }else{
                                self.arrayTop.append(UIImage())
                            }
                            
                            if self.bottom.count > 0 {
                                self.arrayBottom.append(self.bottom[i % (self.bottom.count)])
                            }else{
                                self.arrayBottom.append(UIImage())
                            }
                            
                            if self.wool.count > 0 {
                                self.arrayWool.append(self.wool[i % (self.wool.count)])
                            }else{
                                self.arrayWool.append(UIImage())
                            }
                            i += 1
                        }
                        print("Reached 184")
                        
                        self.bottom.removeAll()
                        self.top.removeAll()
                        self.wool.removeAll()
                        print(self.bottom)
                        
                        print("Reached 191")
                        
                        self.array.append(self.arrayTop[0])
                        self.array.append(self.arrayBottom[0])
                        self.array.append(self.arrayWool[0])
                        
                        self.imageFrame.reloadData()

                        
                    }
                }
            }
        })
        
    }
    func updateImage(rightSwipe : Bool){
        
        if rightSwipe{
            if index < arrayTop.count - 1{
                index += 1
            }
            array[0] = arrayTop[index % arrayTop.count]
            array[1] = arrayBottom[index % arrayBottom.count]
            array[2] = arrayWool[index % arrayWool.count]
        } else {
            
            if index > 0{
                index -= 1
            }
            array[0] = arrayTop[index]
            array[1] = arrayBottom[index]
            array[2] = arrayWool[index]
        }
        imageFrame.reloadData()
        
    }
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: view)
        let label = gestureRecognizer.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = abs(min(100 / xFromCenter, 1))
        
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        
        label.transform = stretchAndRotation
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended{
            if label.center.x < 100{
                print("Right")
                updateImage(rightSwipe: false)
            }
            else if label.center.x > self.view.bounds.width - 100{
                print("Left")
                updateImage(rightSwipe: true)
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
            
            label.transform = stretchAndRotation
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        }
    }
    
    
    
    func getTemperature(city : String) -> (Double){
        let semaphore = DispatchSemaphore(value: 0)
        
        var temperature = 0.0
        
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=" + city.replacingOccurrences(of: " ", with: "%20") + ",uk&appid=35b14cc943b556ed387e6f159cfb2dbe"){
            
            print("line 226")
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    print("line 275")
                    print(error!)
                    
                }else {
                    print("line 279")
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            if let a = (jsonResult["main"] as? NSDictionary)
                            {
                                if let temperatureC = a["temp"] as? Double
                                {
                                    temperature = temperatureC
                                    
                                }else {
                                    print("Temperature is not being assigned")
                                }
                                
                            } else {
                                print("a is not being assigned")
                            }
                        }
                            
                        catch {
                            
                            print("JSON Processing Failed")
                            
                        }
                        
                    }
                }
                semaphore.signal()
            }
            
            task.resume()
            semaphore.wait()
            
        }
            
        else {
            
            print("Couldn't find weather for that city, please try another")
        }
        
        print("The returning temp is \(temperature - 273.15)")
        return temperature - 273.15
    }
}
