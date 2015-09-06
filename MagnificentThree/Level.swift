//
//  Level.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/13/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import Foundation

let NumColumns = 9,
    NumRows = 9

class Level {
    
    // MARK: Public variables
    
    var targetScore = 0,
        maximumMoves = 0,
        comboMultiplier = 0
    
    // MARK: Private variables
    
    private var items = Array2D<Item>(columns: NumColumns, rows: NumRows),
                tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows),
                possibleSwaps = Set<Swap>(),
                removedRocks = [Tile]()
    
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
                            tiles[column, tileRow] = Tile(column: column, row: tileRow, rocky: false)
                        }
                        else if value == 2 {
                            tiles[column, tileRow] = Tile(column: column, row: tileRow, rocky: true)
                        }
                    }
                }
                
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
            }
        }
    }
    
    // MARK: Public methods
    
    func itemAtColumn(column: Int, row: Int) -> Item? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return items[column, row]
    }
    
    func isRockAtColumn(column: Int, row: Int) -> Bool {
        var isRock = false
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        if let tile = tiles[column, row] {
            isRock = tile.rocky
        }
        return isRock
    }
    
    func shuffle() -> Set<Item> {
        var set: Set<Item>
        do {
            set = createInitialItems()
            detectPossibleSwaps()
            //println("possible swaps: \(possibleSwaps)")
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
                        // Have an item in this spot? If there is no tile, there is no item.
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
        var horizontalChains = detectHorizontalMatches()
        var verticalChains = detectVerticalMatches()
        var lshapedChains = detectLshapedMatches(horizontalChains, verticalChains: verticalChains)
        
        removeItems(horizontalChains)
        removeItems(verticalChains)
        removeItems(lshapedChains)
        
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        calculateScores(lshapedChains)
        
        if lshapedChains.count > 0 {
            return lshapedChains
        }
        else {
            return horizontalChains.union(verticalChains).union(lshapedChains)
        }
    }
    
    func removeRocks() {
        for tile in removedRocks {
            if let t = tiles[tile.column, tile.row] {
                t.rocky = false
                tiles[tile.column, tile.row] = t
            }
        }
    }
    
    func markForDelete(rock: Tile) {
        self.removedRocks.append(rock)
    }
    
    func removeBombedItems(type: ItemType) -> Set<Chain> {
        var bombChains = detectBombMatches(type)
        
        removeItems(bombChains)
        calculateBombScores(bombChains)
        
        return bombChains
    }
    
    func fillHoles() -> [[Item]] {
        var columns = [[Item]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Item]()
            for row in 0..<NumRows {
                // 2
                if let tile = tiles[column, row] {
                    if !tile.rocky && items[column, row] == nil {
                        // 3
                        for lookup in (row + 1)..<NumRows {
                            if let tile = tiles[column, lookup] {
                                if !tile.rocky {
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
    
    func topUpItems() -> [[Item]] {
        var columns = [[Item]]()
        var itemType: ItemType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Item]()
            // 1
            for var row = NumRows - 1; row >= 0 && items[column, row] == nil; --row {
                // 2
                if let tile = tiles[column, row] {
                    if !tile.rocky {
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
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
    func rockItems() -> Set<Tile> {
        
        var set = Set<Tile>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if let tile = tiles[column, row] {
                    // Is it a rocky tile?
                    if tile.rocky {
                        set.insert(tile)
                    }
                }
            }
        }
        
        return set
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
    
    private func detectLshapedMatches(horizontalChains: Set<Chain>, verticalChains: Set<Chain>) -> Set<Chain> {
        var set = Set<Chain>()
        var found = false
        
        for chain in horizontalChains {
            let fItem = chain.firstItem()
            let lItem = chain.lastItem()
            found = false
            
            for vchain in verticalChains {
                for item in vchain.items {
                    
                    if item.itemType == fItem.itemType || item.itemType == lItem.itemType {
                        let c = Chain(chainType: .Lshaped)
                        for i in chain.items {
                            c.addItem(i)
                            chain.removeItem(i)
                        }
                        for i in vchain.items {
                            c.addItem(i)
                            vchain.removeItem(i)
                        }
                        set.insert(c)
                        found = true
                    }
                    break
                }
                if found {
                    break
                }
            }
            
            if found {
                break
            }
        }
        
        if (found) {
            horizontalChains.subtract(set)
            verticalChains.subtract(set)
        }
        
        return set
    }
    
    private func detectBombMatches(type: ItemType) -> Set<Chain> {
        var set = Set<Chain>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if let tile = tiles[column, row] {
                    if !tile.rocky {
                        
                        if let item = items[column, row] {
                            let matchType = item.itemType
                            
                            if items[column, row]?.itemType == type {
                                
                                let chain = Chain(chainType: .Bomb)
                                chain.addItem(items[column, row]!)
                                set.insert(chain)
                            }
                        }
                    }
                }
            }
        }
        
        return set
    }
    
    private func removeItems(chains: Set<Chain>) {
        for chain in chains {
            for item in chain.items {
                if !self.isRockAtColumn(item.column, row: item.row) {
                    items[item.column, item.row] = nil
                }
            }
        }
    }
    
    private func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        var value = 60
        for chain in chains {
            if chain.chainType == .Lshaped {
                value = 120
            }
            else {
                value = 60
            }
            chain.score = value * (chain.length - 2) * comboMultiplier
            ++comboMultiplier
        }
    }
    
    private func calculateBombScores(chains: Set<Chain>) {
        for chain in chains {
            chain.score = 20
        }
    }
}