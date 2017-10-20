//
//  DGame.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 9/7/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import Foundation
import CoreData

@objc(DGame)
class DGame: NSManagedObject {

    @NSManaged var uuid: String
    @NSManaged var date: Date
    @NSManaged var score: NSNumber
    @NSManaged var type: NSNumber
}
