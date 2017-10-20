//
//  Chain.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/18/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    
    // MARK: Variables
    
    var score = 0
    var items = [Item]()
    
    enum ChainType: CustomStringConvertible {
        case horizontal
        case vertical
        case lshaped
        case bomb
        
        var description: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            case .lshaped: return "Lshaped"
            case .bomb: return "Bomb"
            }
        }
    }
    
    var chainType: ChainType
    
    // MARK: Init
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    // MARK: Public methods
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func removeItem(_ item: Item) {
        if let index = find(items, item) {
            items.remove(at: index)
        }
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
    
    // MARK: Hashable
    
    var hashValue: Int {
        return reduce(items, 0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.items == rhs.items
}
