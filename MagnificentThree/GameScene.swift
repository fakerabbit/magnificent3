//
//  GameScene.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/12/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

private let kMovableNodeName = "movable"

class GameScene: SKScene {
    
    // MARK: Audio
    
    let invalidSwapSound = SKAction.playSoundFileNamed("whip.mp3", waitForCompletion: false)
    let fallingItemSound = SKAction.playSoundFileNamed("spurs.mp3", waitForCompletion: false)
    let swapSound = SKAction.playSoundFileNamed("cock.mp3", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false)
    let addItemSound = SKAction.playSoundFileNamed("spurs.mp3", waitForCompletion: false)
    let cowboySound = SKAction.playSoundFileNamed("yeehaw.mp3", waitForCompletion: false)
    
    // MARK: Variables
    
    var shuffle: NodeButton?,
        menu: NodeButton?
    
    var leaveSign: LeaveSign?
    
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
        tilesLayer = SKNode(),
        cropLayer = SKCropNode(),
        maskLayer = SKNode()
    
    private var swipeFromColumn: Int?,
                swipeFromRow: Int?,
                selectionSprite = SKSpriteNode(),
                backgroundImg: SKSpriteNode?
    
    var swipeHandler: ((Swap) -> ())?,
        bombHandler: ((ItemType) -> ())?
    
    var cowboy : SKSpriteNode!,
        cowboyWalkingFrames : [SKTexture]!,
        bomb : SKSpriteNode!,
        bombShiningFrames : [SKTexture]!,
        selectedNode = SKSpriteNode(),
        fires = [SKEmitterNode]()
    
    var smoke: SKEmitterNode?
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        swipeFromColumn = nil
        swipeFromRow = nil
        
        let bgNum = Int(arc4random_uniform(11))
        //println("\(bgNum)")
        backgroundImg = SKSpriteNode(imageNamed: "Bg\(bgNum)")
        //let background = SKSpriteNode(imageNamed: "Bg12")
        addChild(backgroundImg!)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        gameLayer.addChild(cropLayer)
        
        maskLayer.position = layerPosition
        cropLayer.maskNode = maskLayer
        
        itemsLayer.position = layerPosition
        cropLayer.addChild(itemsLayer)

        
        targetLbl = SKLabelNode(text: "Target:")
        targetLbl?.fontName = "Sahara"
        targetLbl?.fontColor = UIColor.whiteColor()
        targetLbl?.fontSize = 14
        addChild(targetLbl!)
        targetLbl?.position = CGPointMake(0, size.height/2.2)
        
        movesLbl = SKLabelNode(text: "Moves:")
        movesLbl?.fontName = "Sahara"
        movesLbl?.fontColor = UIColor.whiteColor()
        movesLbl?.fontSize = 14
        addChild(movesLbl!)
        movesLbl?.position = CGPointMake(size.width/4.8, size.height/2.2)
        
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
        target?.position = CGPointMake(0, size.height/2.4)//CGPointMake(-size.width/2.5, size.height/2.4)
        
        moves = SKLabelNode(text: "0")
        moves?.fontName = "Sahara"
        moves?.fontColor = UIColor.whiteColor()
        moves?.fontSize = 20
        addChild(moves!)
        moves?.position = CGPointMake(size.width/4.8, size.height/2.4)//CGPointMake(0, size.height/2.4)
        
        score = SKLabelNode(text: "0")
        score?.fontName = "Sahara"
        score?.fontColor = UIColor.whiteColor()
        score?.fontSize = 20
        addChild(score!)
        score?.position = CGPointMake(size.width/2.5, size.height/2.4)
        
        shuffle = NodeButton(normalImage: "Shuffle", selectedImage: "ShuffleOn", tag: 1)
        if let size = shuffle?.size {
            shuffle?.size = CGSizeMake(size.width/2, size.height/2)
        }
        shuffle?.position = CGPointMake(size.width/3, -(size.height/2 - shuffle!.size.height))
        addChild(shuffle!)
        
        menu = NodeButton(normalImage: "Menu", selectedImage: "MenuOn", tag: 2)
        if let size = menu?.size {
            menu?.size = CGSizeMake(size.width/2, size.height/2)
        }
        menu?.position = CGPointMake(-size.width/3, size.height/2.2)
        addChild(menu!)
    }
    
    // MARK: Scene methods
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Cowboy
        let cowboyAnimatedAtlas = SKTextureAtlas(named: "CowboyImages")
        var walkFrames = [SKTexture]()
        
        var numImages = cowboyAnimatedAtlas.textureNames.count
        for var i=1; i<=numImages/2; i++ {
            let cowboyTextureName = "cowboy\(i)"
            walkFrames.append(cowboyAnimatedAtlas.textureNamed(cowboyTextureName))
        }
        
        cowboyWalkingFrames = walkFrames
        
        var firstFrame = cowboyWalkingFrames[0]
        cowboy = SKSpriteNode(texture: firstFrame)
        cowboy.position = CGPoint(x:-view.frame.size.width, y:-(CGRectGetMidY(view.frame) - cowboy.size.height/2))
        addChild(cowboy)
        
        // Bomb
        let bombAnimatedAtlas = SKTextureAtlas(named: "BombImages")
        var bombFrames = [SKTexture]()
        
        numImages = bombAnimatedAtlas.textureNames.count
        for var i=1; i<=numImages/2; i++ {
            let bombTextureName = "bomb\(i)"
            bombFrames.append(bombAnimatedAtlas.textureNamed(bombTextureName))
        }
        
        bombShiningFrames = bombFrames
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Public methods
    
    func addSpritesForItems(items: Set<Item>) {
        for item in items {
            let sprite = SKSpriteNode(imageNamed: item.itemType.spriteName)
            sprite.position = pointForColumn(item.column, row:item.row)
            itemsLayer.addChild(sprite)
            item.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.runAction(
                SKAction.sequence([
                    SKAction.waitForDuration(0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeInWithDuration(0.25),
                        SKAction.scaleTo(1.0, duration: 0.25)
                        ])
                    ]))
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
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    tileNode.position = pointForColumn(column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        for row in 0...NumRows {
            for column in 0...NumColumns {
                let topLeft     = (column > 0) && (row < NumRows)
                    && level.tileAtColumn(column - 1, row: row) != nil
                let bottomLeft  = (column > 0) && (row > 0)
                    && level.tileAtColumn(column - 1, row: row - 1) != nil
                let topRight    = (column < NumColumns) && (row < NumRows)
                    && level.tileAtColumn(column, row: row) != nil
                let bottomRight = (column < NumColumns) && (row > 0)
                    && level.tileAtColumn(column, row: row - 1) != nil
                
                // The tiles are named from 0 to 15, according to the bitmask that is
                // made by combining these four values.
                let value = Int(topLeft) | Int(topRight) << 1 | Int(bottomLeft) << 2 | Int(bottomRight) << 3
                
                // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
                if value != 0 && value != 6 && value != 9 {
                    let name = String(format: "Tile_%ld", value)
                    let tileNode = SKSpriteNode(imageNamed: name)
                    var point = pointForColumn(column, row: row)
                    point.x -= TileWidth/2
                    point.y -= TileHeight/2
                    tileNode.position = point
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func showSelectionIndicatorForItem(item: Item) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = item.sprite {
            let texture = SKTexture(imageNamed: item.itemType.highlightedSpriteName)
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
    
    func removeAllCookieSprites() {
        itemsLayer.removeAllChildren()
    }
    
    func makeSureItemsAreRemoved(items: [Item]) {
        for fire: SKEmitterNode in self.fires {
            fire.removeFromParent()
        }
        self.fires.removeAll(keepCapacity: false)
        for item in items {
            if let sprite = item.sprite {
                sprite.removeFromParent()
            }
        }
    }
    
    func showLeaveSign() {
        
        if leaveSign == nil {
            
            leaveSign = LeaveSign(tag: 333)
            leaveSign?.position = CGPointMake(0, -size.height)
            leaveSign?.size = CGSizeMake(size.width - 25, leaveSign!.size.height)
            self.addChild(leaveSign!)
            
            let move = SKAction.moveTo(CGPointMake(0, -(size.height/2 - leaveSign!.size.height/2)), duration: 0.5)
            move.timingMode = .EaseOut
            leaveSign?.runAction(move, completion: { () -> Void in
            })
        }
    }
    
    func hideLeaveSign() {
        
        if leaveSign != nil {
            
            let move = SKAction.moveTo(CGPointMake(0, -size.height), duration: 0.5)
            move.timingMode = .EaseOut
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, remove])
            leaveSign?.runAction(sequence, completion: {
                self.leaveSign = nil
            })
        }
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
        
        let sequencer = Sequencer()
        
        for chain in chains {
            
            sequencer.enqueueStep() { result, next in
                self.animateScoreForChain(chain)
                next(nil)
            }
            
            for item in chain.items {
                if let sprite = item.sprite {
                    
                    sequencer.enqueueStep() { result, next in
                        //println("removing sprite: \(sprite), for item: \(item)")
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        let completeAction = SKAction.sequence([scaleAction, SKAction.removeFromParent()])
                        sprite.runAction(completeAction)
                        next(nil)
                    }
                    
                    sequencer.enqueueStep() { result, next in
                        if let myParticlePath = NSBundle.mainBundle().pathForResource("fire", ofType: "sks") {
                            if let fParticles = NSKeyedUnarchiver.unarchiveObjectWithFile(myParticlePath) as? SKEmitterNode {
                                fParticles.position = sprite.position
                                self.itemsLayer.addChild(fParticles)
                                self.fires.append(fParticles)
                            }
                        }
                        next(nil)
                    }
                }
            }
        }
        
        sequencer.enqueueStep() { result, next in
            self.runAction(self.matchSound)
            next(nil)
        }
        
        sequencer.enqueueStep() { result, next in
            self.runAction(SKAction.waitForDuration(0.3), completion: completion)
        }
        
        sequencer.run()
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
                let sprite = SKSpriteNode(imageNamed: item.itemType.spriteName)
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
        
        if level.comboMultiplier > 3 {
            walkingCowboy()
            addBomb()
        }
    }
    
    func walkingCowboy() {
        if cowboy.actionForKey("walkingInPlaceCowboy") == nil {
            let animeAction = SKAction.repeatActionForever(
                SKAction.animateWithTextures(cowboyWalkingFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true))
            cowboy.runAction(animeAction,withKey:"walkingInPlaceCowboy")
            let moveAction = SKAction.moveBy(CGVector(dx: CGRectGetMidX(self.view!.frame) + cowboy.size.width/1.2, dy: 0), duration: 0.7)
            let waitAction = SKAction.waitForDuration(1)
            let moveBackAction = SKAction.moveBy(CGVector(dx: -(CGRectGetMidX(self.view!.frame) + cowboy.size.width/1.2), dy: 0), duration: 0.7)
            let fullSequence = SKAction.sequence([moveAction, cowboySound, waitAction, moveBackAction])
            cowboy.runAction(fullSequence, completion: { () -> Void in
                self.cowboyMoveEnded()
            })
        }
    }
    
    func cowboyMoveEnded() {
        cowboy.removeAllActions()
    }
    
    func addBomb() {
        
        if bomb == nil {
            let firstFrame = bombShiningFrames[0]
            bomb = SKSpriteNode(texture: firstFrame)
            bomb.position = CGPoint(x: -(CGRectGetMidX(self.view!.frame) - bomb.size.width), y: -(CGRectGetMidY(self.view!.frame) - bomb.size.height/1.5))
            bomb.name = kMovableNodeName
            
            let animeAction = SKAction.repeatActionForever(
                SKAction.animateWithTextures(bombShiningFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true))
            bomb.runAction(animeAction,withKey:"bombShiningAnime")
            
            if let myParticlePath = NSBundle.mainBundle().pathForResource("smoke", ofType: "sks") {
                self.smoke = NSKeyedUnarchiver.unarchiveObjectWithFile(myParticlePath) as? SKEmitterNode
                self.smoke?.position = CGPointMake(bomb.position.x, bomb.position.y)
                self.addChild(self.smoke!)
            }
            
            addChild(bomb)
        }
    }
    
    func removeBomb() {
        if selectedNode.name != nil {
            if selectedNode.actionForKey("removing") == nil {
                let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                scaleAction.timingMode = .EaseOut
                selectedNode.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                    withKey:"removing")
                bomb = nil
                selectedNode = SKSpriteNode()
                self.smoke?.removeFromParent()
            }
        }
    }
    
    // MARK: Touch events
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(itemsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            if let item = level.itemAtColumn(column, row: row) {
                
                showSelectionIndicatorForItem(item)
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
        else {
            let touch = touches.first as! UITouch
            let positionInScene = touch.locationInNode(self)
            
            selectNodeForTouch(positionInScene)
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
        
        if swipeFromColumn == nil {
            let touch = touches.first as! UITouch
            let positionInScene = touch.locationInNode(self)
            let previousPosition = touch.previousLocationInNode(self)
            let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
            
            panForTranslation(translation)
        }
        else {
            let touch = touches.first as! UITouch
            let location = touch.locationInNode(itemsLayer)
            
            let (success, column, row) = convertPoint(location)
            if success {
                
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
                
                if horzDelta != 0 || vertDelta != 0 {
                    trySwapHorizontal(horzDelta, vertical: vertDelta)
                    hideSelectionIndicator()
                    swipeFromColumn = nil
                }
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
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        swipeFromColumn = nil
        swipeFromRow = nil
        
        if selectedNode.name != nil {
            
            let touch = touches.first as! UITouch
            let location = touch.locationInNode(itemsLayer)
            
            let (success, column, row) = convertPoint(location)
            if success {
                
                if let item = level.itemAtColumn(column, row: row) {
                    
                    if let handler = bombHandler {
                        let type = item.itemType
                        handler(type)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
    
    func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
        let winSize = self.view!.frame.size
        var retval = aNewPosition
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(backgroundImg!.size.width) + winSize.width))
        retval.y = self.position.y
        
        return retval
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        
        if selectedNode.name == kMovableNodeName {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            smoke?.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        } else {
            let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            backgroundImg?.position = self.boundLayerPos(aNewPosition)
        }
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * M_PI)
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        let touchedNode = self.nodeAtPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                selectedNode = touchedNode as! SKSpriteNode
            }
        }
    }
}
