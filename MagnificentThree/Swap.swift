//
//  Swap.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/13/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

struct Swap: Printable, Hashable {
    
    let itemA: Item
    let itemB: Item
    
    init(itemA: Item, itemB: Item) {
        self.itemA = itemA
        self.itemB = itemB
    }
    
    var description: String {
        return "swap \(itemA) with \(itemB)"
    }
    
    // MARK: Hash
    
    var hashValue: Int {
        return itemA.hashValue ^ itemB.hashValue
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.itemA == rhs.itemA && lhs.itemB == rhs.itemB) ||
        (lhs.itemB == rhs.itemA && lhs.itemA == rhs.itemB)
}
