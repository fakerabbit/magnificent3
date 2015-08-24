//
//  GameScene.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/12/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: Audio
    
    let invalidSwapSound = SKAction.playSoundFileNamed("whip.wav", waitForCompletion: false)
    let fallingItemSound = SKAction.playSoundFileNamed("spurs.wav", waitForCompletion: false)
    let swapSound = SKAction.playSoundFileNamed("cock.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("gunshot.wav", waitForCompletion: false)
    let addItemSound = SKAction.playSoundFileNamed("banjo.wav", waitForCompletion: false)
    
    // MARK: Variables
    
    var level: Level!
    
    var targetLbl: SKLabelNode?,
        movesLbl: SKLabelNode?,
        scoreLbl: SKLabelNode?,
        target: SKLabelNode?,
        moves: SKLabelNode?,
        score: SKLabelNode?
    
    let TileWidth: CGFloat = 32.0,
        TileHeight: CGFloat = 36.0
    
    let topPad: CGFloat = 10.0
    
    let gameLayer = SKNode(),
        itemsLayer = SKNode(),
        tilesLayer = SKNode()
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    private var selectionSprite = SKSpriteNode()
    private var selectedItem: Item?
    
    var swipeHandler: ((Swap) -> ())?
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        swipeFromColumn = nil
        swipeFromRow = nil
        
        let background = SKSpriteNode(imageNamed: "BgDesert")
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        itemsLayer.position = layerPosition
        gameLayer.addChild(itemsLayer)
        
        targetLbl = SKLabelNode(text: "Target:")
        targetLbl?.fontName = "Sahara"
        targetLbl?.fontColor = UIColor.whiteColor()
        targetLbl?.fontSize = 14
        addChild(targetLbl!)
        targetLbl?.position = CGPointMake(-size.width/2.5, size.height/2.2)
        
        movesLbl = SKLabelNode(text: "Moves:")
        movesLbl?.fontName = "Sahara"
        movesLbl?.fontColor = UIColor.whiteColor()
        movesLbl?.fontSize = 14
        addChild(movesLbl!)
        movesLbl?.position = CGPointMake(0, size.height/2.2)
        
        scoreLbl = SKLabelNode(text: "Score:")
        scoreLbl?.fontName = "Sahara"
        scoreLbl?.fontColor = UIColor.whiteColor()
        scoreLbl?.fontSize = 14
        addChild(scoreLbl!)
        scoreLbl?.position = CGPointMake(size.width/2.5, size.height/2.2)
        
        target = SKLabelNode(text: "0")
        target?.fontName = "Sahara"
        target?.fontColor = UIColor.whiteColor()
        target?.fontSize = 20
        addChild(target!)
        target?.position = CGPointMake(-size.width/2.5, size.height/2.4)
        
        moves = SKLabelNode(text: "0")
        moves?.fontName = "Sahara"
        moves?.fontColor = UIColor.whiteColor()
        moves?.fontSize = 20
        addChild(moves!)
        moves?.position = CGPointMake(0, size.height/2.4)
        
        score = SKLabelNode(text: "0")
        score?.fontName = "Sahara"
        score?.fontColor = UIColor.whiteColor()
        score?.fontSize = 20
        addChild(score!)
        score?.position = CGPointMake(size.width/2.5, size.height/2.4)
    }
    
    // MARK: Scene methods
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Public methods
    
    func addSpritesForItems(items: Set<Item>) {
        for item in items {
            let sprite = SKSpriteNode(texture: item.itemType.spriteTexture)
            sprite.position = pointForColumn(item.column, row:item.row)
            itemsLayer.addChild(sprite)
            item.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(texture: sprites().tile())
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func showSelectionIndicatorForCookie(item: Item) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = item.sprite {
            let texture = item.itemType.highlightedSpriteTexture
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()]))
    }
    
    // MARK: Animations
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.itemA.sprite!
        let spriteB = swap.itemB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
        
        runAction(swapSound)
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.itemA.sprite!
        let spriteB = swap.itemB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        
        runAction(invalidSwapSound)
    }
    
    func animateMatchedItems(chains: Set<Chain>, completion: () -> ()) {
        for chain in chains {
            
            animateScoreForChain(chain)
            
            for item in chain.items {
                if let sprite = item.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                            withKey:"removing")
                    }
                }
            }
        }
        runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    func animateFallingItems(columns: [[Item]], completion: () -> ()) {
        // 1
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, item) in enumerate(array) {
                let newPosition = pointForColumn(item.column, row: item.row)
                // 2
                let delay = 0.05 + 0.15*NSTimeInterval(idx)
                // 3
                let sprite = item.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([moveAction, fallingItemSound])]))
            }
        }
        // 6
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateNewItems(columns: [[Item]], completion: () -> ()) {
        // 1
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            // 2
            let startRow = array[0].row + 1
            
            for (idx, item) in enumerate(array) {
                // 3
                let sprite = SKSpriteNode(texture: item.itemType.spriteTexture)
                sprite.position = pointForColumn(item.column, row: startRow)
                itemsLayer.addChild(sprite)
                item.sprite = sprite
                // 4
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                // 5
                let duration = NSTimeInterval(startRow - item.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                // 6
                let newPosition = pointForColumn(item.column, row: item.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            SKAction.fadeInWithDuration(0.05),
                            moveAction,
                            addItemSound])
                        ]))
            }
        }
        // 7
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateScoreForChain(chain: Chain) {
        
        // Figure out what the midpoint of the chain is.
        let firstSprite = chain.firstItem().sprite!
        let lastSprite = chain.lastItem().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        // Add a label for the score that slowly floats up.
        let scoreLabel = SKLabelNode(fontNamed: "Sahara")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        itemsLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .EaseOut
        scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    // MARK: Touch events
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(itemsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            if let item = level.itemAtColumn(column, row: row) {
                
                if selectedItem != nil {
                    let swap = Swap(itemA: selectedItem!, itemB: item)
                    if level.isPossibleSwap(swap) {
                        if let handler = swipeHandler {
                            hideSelectionIndicator()
                            handler(swap)
                        }
                    }
                    else {
                        let swap = Swap(itemA: item, itemB: selectedItem!)
                        if level.isPossibleSwap(swap) {
                            if let handler = swipeHandler {
                                hideSelectionIndicator()
                                handler(swap)
                            }
                        }
                        else {
                            showSelectionIndicatorForCookie(item)
                            swipeFromColumn = column
                            swipeFromRow = row
                            selectedItem = item
                        }
                    }
                }
                else {
                    showSelectionIndicatorForCookie(item)
                    swipeFromColumn = column
                    swipeFromRow = row
                    selectedItem = item
                }
            }
        }
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 1
        if swipeFromColumn == nil { return }
        
        // 2
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(itemsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            // 3
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            // 4
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                // 5
                swipeFromColumn = nil
            }
        }
    }
    
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        // 1
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        // 2
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        // 3
        if let toItem = level.itemAtColumn(toColumn, row: toRow) {
            if let fromItem = level.itemAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                // 4
                if let handler = swipeHandler {
                    let swap = Swap(itemA: fromItem, itemB: toItem)
                    handler(swap)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
}
