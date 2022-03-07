//
//  Tile.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/10/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

class Tile: CustomStringConvertible, Hashable {
    
    // MARK: variables
    
    var column: Int,
        row: Int,
        rocky: Bool,
        sprite: SKSpriteNode?
    
    // MARK: Init
    
    init(column: Int, row: Int, rocky: Bool) {
        self.column = column
        self.row = row
        self.rocky = rocky
    }
    
    // MARK: Public methods
    
    var description: String {
        return "rocky:\(rocky) square:(\(column),\(row))"
    }
    
    // MARK: Hash
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(row*10 + column)
    }
}

func ==(lhs: Tile, rhs: Tile) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
