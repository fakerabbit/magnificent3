//
//  Level.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/13/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    
    // MARK: Private variables
    
    private var items = Array2D<Item>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = Set<Swap>()
    
    // MARK: Init
    
    init(filename: String) {
        // 1
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            // 2
            if let tilesArray: AnyObject = dictionary["tiles"] {
                // 3
                for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {
                    // 4
                    let tileRow = NumRows - row - 1
                    // 5
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Public methods
    
    func itemAtColumn(column: Int, row: Int) -> Item? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return items[column, row]
    }
    
    func shuffle() -> Set<Item> {
        var set: Set<Item>
        do {
            set = createInitialItems()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        }
            while possibleSwaps.count == 0
        
        return set
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func performSwap(swap: Swap) {
        let columnA = swap.itemA.column
        let rowA = swap.itemA.row
        let columnB = swap.itemB.column
        let rowB = swap.itemB.row
        
        items[columnA, rowA] = swap.itemB
        swap.itemB.column = columnA
        swap.itemB.row = rowA
        
        items[columnB, rowB] = swap.itemA
        swap.itemA.column = columnB
        swap.itemA.row = rowB
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let item = items[column, row] {
                    
                    // Is it possible to swap this cookie with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = items[column + 1, row] {
                            // Swap them
                            items[column, row] = other
                            items[column + 1, row] = item
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                    set.insert(Swap(itemA: item, itemB: other))
                            }
                            
                            // Swap them back
                            items[column, row] = item
                            items[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = items[column, row + 1] {
                            items[column, row] = other
                            items[column, row + 1] = item
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                    set.insert(Swap(itemA: item, itemB: other))
                            }
                            
                            // Swap them back
                            items[column, row] = item
                            items[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeItems(horizontalChains)
        removeItems(verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    func fillHoles() -> [[Item]] {
        var columns = [[Item]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Item]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && items[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let item = items[column, lookup] {
                            // 4
                            items[column, lookup] = nil
                            items[column, row] = item
                            item.row = row
                            // 5
                            array.append(item)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpCookies() -> [[Item]] {
        var columns = [[Item]]()
        var itemType: ItemType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Item]()
            // 1
            for var row = NumRows - 1; row >= 0 && items[column, row] == nil; --row {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newItemType: ItemType
                    do {
                        newItemType = ItemType.random()
                    } while newItemType == itemType
                    itemType = newItemType
                    // 4
                    let item = Item(column: column, row: row, itemType: itemType)
                    items[column, row] = item
                    array.append(item)
                }
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    // MARK: Private methods
    
    private func createInitialItems() -> Set<Item> {
        var set = Set<Item>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                    
                    // 2
                    var itemType: ItemType
                    do {
                        itemType = ItemType.random()
                    }
                        while (column >= 2 &&
                            items[column - 1, row]?.itemType == itemType &&
                            items[column - 2, row]?.itemType == itemType)
                            || (row >= 2 &&
                                items[column, row - 1]?.itemType == itemType &&
                                items[column, row - 2]?.itemType == itemType)
                    
                    // 3
                    let item = Item(column: column, row: row, itemType: itemType)
                    items[column, row] = item
                    
                    // 4
                    set.insert(item)
                }
            }
        }
        return set
    }
    
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let itemType = items[column, row]!.itemType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && items[i, row]?.itemType == itemType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && items[i, row]?.itemType == itemType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && items[column, i]?.itemType == itemType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && items[column, i]?.itemType == itemType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2 ; {
                // 3
                if let item = items[column, row] {
                    let matchType = item.itemType
                    // 4
                    if items[column + 1, row]?.itemType == matchType &&
                        items[column + 2, row]?.itemType == matchType {
                            // 5
                            let chain = Chain(chainType: .Horizontal)
                            do {
                                chain.addItem(items[column, row]!)
                                ++column
                            }
                                while column < NumColumns && items[column, row]?.itemType == matchType
                            
                            set.insert(chain)
                            continue
                    }
                }
                // 6
                ++column
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let item = items[column, row] {
                    let matchType = item.itemType
                    
                    if items[column, row + 1]?.itemType == matchType &&
                        items[column, row + 2]?.itemType == matchType {
                            
                            let chain = Chain(chainType: .Vertical)
                            do {
                                chain.addItem(items[column, row]!)
                                ++row
                            }
                                while row < NumRows && items[column, row]?.itemType == matchType
                            
                            set.insert(chain)
                            continue
                    }
                }
                ++row
            }
        }
        return set
    }
    
    private func removeItems(chains: Set<Chain>) {
        for chain in chains {
            for item in chain.items {
                items[item.column, item.row] = nil
            }
        }
    }
}