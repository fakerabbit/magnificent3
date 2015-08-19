//
//  Chain.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/18/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import Foundation

class Chain: Hashable, Printable {
    var items = [Item]()
    
    enum ChainType: Printable {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addItem(item: Item) {
        items.append(item)
    }
    
    func firstItem() -> Item {
        return items[0]
    }
    
    func lastItem() -> Item {
        return items[items.count - 1]
    }
    
    var length: Int {
        return items.count
    }
    
    var description: String {
        return "type:\(chainType) items:\(items)"
    }
    
    var hashValue: Int {
        return reduce(items, 0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.items == rhs.items
}