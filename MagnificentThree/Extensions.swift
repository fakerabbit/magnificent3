//
//  Extensions.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/10/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit

extension Dictionary {
    static func loadJSONFromBundle(_ filename: String) -> Dictionary<String, AnyObject>? {
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            
            var error: NSError?
            let data = Data(bytesNoCopy: path, count: NSData.ReadingOptions(), deallocator: &error)
            if let data = data {
                
                let dictionary: AnyObject? = JSONSerialization.JSONObjectWithData(data,
                    options: JSONSerialization.ReadingOptions(), error: &error)
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    print("Level file '\(filename)' is not valid JSON: \(error!)")
                    return nil
                }
            } else {
                print("Could not load level file: \(filename), error: \(error!)")
                return nil
            }
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}
