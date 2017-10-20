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
            
            //var error: NSError?
            //let data = Data(bytesNoCopy: path, count: NSData.ReadingOptions(), deallocator: &error)
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let dictionary: Any? = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                return dictionary
            } else {
                print("Level file '\(filename)' is not valid JSON")
                return nil
            }
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}
