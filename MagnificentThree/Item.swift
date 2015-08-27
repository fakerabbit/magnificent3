//
//  Item.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/12/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

enum ItemType: Int, Printable {
    case Unknown = 0, Star, Cactus, Pistols, Boots, Hat, Shoe
    
    var spriteName: String {
        let spriteNames = [
            "star",
            "cactus",
            "pistol",
            "boots",
            "hat",
            "shoe"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-highlighted"
    }
    
    static func random() -> ItemType {
        return ItemType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    var description: String {
        return "\(rawValue)"
    }
}

class Item: Printable, Hashable {
    
    // MARK: variables
    
    var column: Int
    var row: Int
    let itemType: ItemType
    var sprite: SKSpriteNode?
    
    // MARK: Init
    
    init(column: Int, row: Int, itemType: ItemType) {
        self.column = column
        self.row = row
        self.itemType = itemType
    }
    
    // MARK: Public methods
    
    var description: String {
        return "type:\(itemType) square:(\(column),\(row))"
    }
    
    // MARK: Hash
    
    var hashValue: Int {
        return row*10 + column
    }
}

func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
