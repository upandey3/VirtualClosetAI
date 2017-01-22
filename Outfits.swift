//
//  File.swift
//  VirtualCloset
//
//  Created by Aakash Patel on 1/21/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation
class Outfits
{
    func getConcepts(input_temperature: Double) -> [String]
    {
        // seven concepts divided into two dictionaries of tops and bottoms
        // tops map to even integers, while bottoms map to odd integers
        
        let tops: [Int: String] = [0:"shirt", 2:"polo", 4:"sweater", 6:"jacket"]
        let bottoms: [Int: String] = [1:"pants", 3:"briefs"]
        
        var outputArray = [String]()
        
        let temperature = input_temperature
        
        // jacket weather
        
        if (temperature <= 10.0)
        {
            outputArray.append("shirt")
            outputArray.append("pants")
            outputArray.append("jacket")
        }
            // sweater weather
            
        else if (temperature > 10.0 && temperature <= 15.0)
        {
            outputArray.append("shirt")
            outputArray.append("pants")
            outputArray.append("sweater")
        }
            // for all temperatures above 15.0
            
        else
        {
            var check = true
            var check_2 = true
            
            var output_concept = ""
            var output_concept_2 = ""
            
            while(check)
            {
                var temp = Int(arc4random_uniform(4))
                
                if (temp == 0 || temp == 2)
                {
                    temp = temp + 1
                    check = false
                }
                
                for (key, value) in bottoms
                {
                    if temp == key
                    {
                        output_concept = value
                    }
                }
            }
            
            while(check_2)
            {
                var temp2 = Int(arc4random_uniform(4))
                
                if (temp2 == 1 || temp2 == 3)
                {
                    temp2 = temp2 - 1
                    check_2 = false
                }
                
                for (key, value) in tops
                {
                    if temp2 == key
                    {
                        output_concept_2 = value
                    }
                }
            }
            outputArray.append(output_concept_2)     //top
            outputArray.append(output_concept)   //bottom
            outputArray.append("")
        }
        return outputArray
    }
}
