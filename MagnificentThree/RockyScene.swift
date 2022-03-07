//
//  RockyScene.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 9/4/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

private let kMovableNodeName = "movable"

class RockyScene: SKScene {
    
    // MARK: Audio
    
    let invalidSwapSound = SKAction.playSoundFileNamed("whip.mp3", waitForCompletion: false),
        fallingItemSound = SKAction.playSoundFileNamed("spurs.mp3", waitForCompletion: false),
        swapSound = SKAction.playSoundFileNamed("cock.mp3", waitForCompletion: false),
        matchSound = SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false),
        addItemSound = SKAction.playSoundFileNamed("spurs.mp3", waitForCompletion: false),
        cowboySound = SKAction.playSoundFileNamed("yeehaw.mp3", waitForCompletion: false)
    
    // MARK: Variables
    
    var level: Level!
    
    var menu: NodeButton?
    
    var leaveSign: LeaveSign?
    
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
        maskLayer = SKNode(),
        rocksLayer = SKNode()
    
    fileprivate var swipeFromColumn: Int?,
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
        //backgroundImg = SKSpriteNode(imageNamed: "Bg10")
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
        
        rocksLayer.position = layerPosition
        gameLayer.addChild(rocksLayer)
        
        targetLbl = SKLabelNode(text: "Target:")
        targetLbl?.fontName = "Sahara"
        targetLbl?.fontColor = UIColor.white
        targetLbl?.fontSize = 14
        addChild(targetLbl!)
        targetLbl?.position = CGPoint(x: 0, y: size.height/2.2)
        
        movesLbl = SKLabelNode(text: "Moves:")
        movesLbl?.fontName = "Sahara"
        movesLbl?.fontColor = UIColor.white
        movesLbl?.fontSize = 14
        addChild(movesLbl!)
        movesLbl?.position = CGPoint(x: size.width/4.8, y: size.height/2.2)
        
        scoreLbl = SKLabelNode(text: "Score:")
        scoreLbl?.fontName = "Sahara"
        scoreLbl?.fontColor = UIColor.white
        scoreLbl?.fontSize = 14
        addChild(scoreLbl!)
        scoreLbl?.position = CGPoint(x: size.width/2.5, y: size.height/2.2)
        
        target = SKLabelNode(text: "0")
        target?.fontName = "Sahara"
        target?.fontColor = UIColor.white
        target?.fontSize = 20
        addChild(target!)
        target?.position = CGPoint(x: 0, y: size.height/2.4)//CGPointMake(-size.width/2.5, size.height/2.4)
        
        moves = SKLabelNode(text: "0")
        moves?.fontName = "Sahara"
        moves?.fontColor = UIColor.white
        moves?.fontSize = 20
        addChild(moves!)
        moves?.position = CGPoint(x: size.width/4.8, y: size.height/2.4)//CGPointMake(0, size.height/2.4)
        
        score = SKLabelNode(text: "0")
        score?.fontName = "Sahara"
        score?.fontColor = UIColor.white
        score?.fontSize = 20
        addChild(score!)
        score?.position = CGPoint(x: size.width/2.5, y: size.height/2.4)
        
        menu = NodeButton(normalImage: "Menu", selectedImage: "MenuOn", tag: 1)
        if let size = menu?.size {
            menu?.size = CGSize(width: size.width/2, height: size.height/2)
        }
        menu?.position = CGPoint(x: -size.width/3, y: size.height/2.2)
        addChild(menu!)
    }
    
    // MARK: Scene methods
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        // Cowboy
        let cowboyAnimatedAtlas = SKTextureAtlas(named: "CowboyImages")
        var walkFrames = [SKTexture]()
        
        var numImages = cowboyAnimatedAtlas.textureNames.count
        for i in 1...numImages/2 {
            let cowboyTextureName = "cowboy\(i)"
            walkFrames.append(cowboyAnimatedAtlas.textureNamed(cowboyTextureName))
        }
        
        cowboyWalkingFrames = walkFrames
        
        let firstFrame = cowboyWalkingFrames[0]
        cowboy = SKSpriteNode(texture: firstFrame)
        cowboy.position = CGPoint(x:-view.frame.size.width, y:-(view.frame.midY - cowboy.size.height/2))
        addChild(cowboy)
        
        // Bomb
        let bombAnimatedAtlas = SKTextureAtlas(named: "BombImages")
        var bombFrames = [SKTexture]()
        
        numImages = bombAnimatedAtlas.textureNames.count
        for i in 1...numImages/2 {
            let bombTextureName = "bomb\(i)"
            bombFrames.append(bombAnimatedAtlas.textureNamed(bombTextureName))
        }
        
        bombShiningFrames = bombFrames
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Public methods
    
    func addSpritesForItems(_ items: Set<Item>) {
        for item in items {
            let sprite = SKSpriteNode(imageNamed: item.itemType.spriteName)
            sprite.position = pointForColumn(item.column, row:item.row)
            itemsLayer.addChild(sprite)
            item.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                        ])
                    ]))
        }
    }
    
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func addTiles() {
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let _ = level.tileAtColumn(column, row: row) {
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
                //let value = Int(topLeft) | Int(topRight) << 1 | Int(bottomLeft) << 2 | Int(bottomRight) << 3
                let value = (topLeft ? 1 : 0) | (topRight ? 1 : 0) << 1 | (bottomLeft ? 1 : 0) << 2 | (bottomRight ? 1 : 0) << 3
                
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
    
    func showSelectionIndicatorForItem(_ item: Item) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = item.sprite {
            let texture = SKTexture(imageNamed: item.itemType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.run(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()]))
    }
    
    func removeAllCookieSprites() {
        itemsLayer.removeAllChildren()
    }
    
    func addSpritesForRocks(_ rocks: Set<Tile>) {
        
        for rock in rocks {
            let sprite = SKSpriteNode(imageNamed: "rock")
            sprite.position = pointForColumn(rock.column, row:rock.row)
            rocksLayer.addChild(sprite)
            rock.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                        ])
                    ]))
        }
    }
    
    func makeSureItemsAreRemoved(_ items: [Item]) {
        for fire: SKEmitterNode in self.fires {
            fire.removeFromParent()
        }
        self.fires.removeAll(keepingCapacity: false)
        for item in items {
            if let sprite = item.sprite {
                sprite.removeFromParent()
            }
        }
    }
    
    func showLeaveSign() {
        
        if leaveSign == nil {
            
            leaveSign = LeaveSign(tag: 333)
            leaveSign?.position = CGPoint(x: 0, y: -size.height)
            leaveSign?.size = CGSize(width: size.width - 25, height: leaveSign!.size.height)
            self.addChild(leaveSign!)
            
            let move = SKAction.move(to: CGPoint(x: 0, y: -(size.height/2 - leaveSign!.size.height/2)), duration: 0.5)
            move.timingMode = .easeOut
            leaveSign?.run(move, completion: { () -> Void in
            })
        }
    }
    
    func hideLeaveSign() {
        
        if leaveSign != nil {
            
            let move = SKAction.move(to: CGPoint(x: 0, y: -size.height), duration: 0.5)
            move.timingMode = .easeOut
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, remove])
            leaveSign?.run(sequence, completion: {
                self.leaveSign = nil
            })
        }
    }
    
    // MARK: Animations
    
    func animateSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.itemA.sprite!
        let spriteB = swap.itemB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: Duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: Duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        run(swapSound)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.itemA.sprite!
        let spriteB = swap.itemB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: Duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: Duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        run(invalidSwapSound)
    }
    
    func animateMatchedItems(_ chains: Set<Chain>, completion: @escaping () -> ()) {
        for chain in chains {
            
            animateScoreForChain(chain)
            
            for item in chain.items {
                
                if level.isRockAtColumn(item.column, row: item.row) {
                    if let tile = level.tileAtColumn(item.column, row: item.row) {
                        level.markForDelete(tile)
                        if let sprite = tile.sprite {
                            if sprite.action(forKey: "removing") == nil {
                                let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                                scaleAction.timingMode = .easeOut
                                sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                    withKey:"removing")
                            }
                        }
                    }
                }
                else if let sprite = item.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                            withKey:"removing")
                        guard let myParticlePath = Bundle.main.path(forResource: "fire", ofType: "sks") else { return }
                        do {
                            let url = URL(fileURLWithPath: myParticlePath)
                            let fileData = try Data(contentsOf: url)
                            if let fParticles = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as? SKEmitterNode {
                                fParticles.position = sprite.position
                                self.itemsLayer.addChild(fParticles)
                                self.fires.append(fParticles)
                            }
                        }
                        catch { }
                    }
                }
            }
        }
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingItems(_ columns: [[Item]], completion: @escaping () -> ()) {
        // 1
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (idx, item) in array.enumerated() {
                let newPosition = pointForColumn(item.column, row: item.row)
                // 2
                let delay = 0.05 + 0.15*TimeInterval(idx)
                // 3
                let sprite = item.sprite!
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction, fallingItemSound])]))
            }
        }
        // 6
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateNewItems(_ columns: [[Item]], completion: @escaping () -> ()) {
        // 1
        var longestDuration: TimeInterval = 0
        
        for array in columns {
            // 2
            let startRow = array[0].row + 1
            
            for (idx, item) in array.enumerated() {
                // 3
                let sprite = SKSpriteNode(imageNamed: item.itemType.spriteName)
                sprite.position = pointForColumn(item.column, row: startRow)
                itemsLayer.addChild(sprite)
                item.sprite = sprite
                // 4
                let delay = 0.1 + 0.2 * TimeInterval(array.count - idx - 1)
                // 5
                let duration = TimeInterval(startRow - item.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                // 6
                let newPosition = pointForColumn(item.column, row: item.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.05),
                            moveAction,
                            addItemSound])
                        ]))
            }
        }
        // 7
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateScoreForChain(_ chain: Chain) {
        
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
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
        
        if level.comboMultiplier > 3 {
            walkingCowboy()
            addBomb()
        }
    }
    
    func walkingCowboy() {
        if cowboy.action(forKey: "walkingInPlaceCowboy") == nil {
            let animeAction = SKAction.repeatForever(
                SKAction.animate(with: cowboyWalkingFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true))
            cowboy.run(animeAction,withKey:"walkingInPlaceCowboy")
            let moveAction = SKAction.move(by: CGVector(dx: self.view!.frame.midX + cowboy.size.width/1.2, dy: 0), duration: 0.7)
            let waitAction = SKAction.wait(forDuration: 1)
            let moveBackAction = SKAction.move(by: CGVector(dx: -(self.view!.frame.midX + cowboy.size.width/1.2), dy: 0), duration: 0.7)
            let fullSequence = SKAction.sequence([moveAction, cowboySound, waitAction, moveBackAction])
            cowboy.run(fullSequence, completion: { () -> Void in
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
            bomb.position = CGPoint(x: -(self.view!.frame.midX - bomb.size.width), y: -(self.view!.frame.midY - bomb.size.height/1.5))
            bomb.name = kMovableNodeName
            
            let animeAction = SKAction.repeatForever(
                SKAction.animate(with: bombShiningFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true))
            bomb.run(animeAction,withKey:"bombShiningAnime")
            guard let myParticlePath = Bundle.main.path(forResource: "smoke", ofType: "sks") else { return }
            do {
                let url = URL(fileURLWithPath: myParticlePath)
                let fileData = try Data(contentsOf: url)
                if let fParticles = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as? SKEmitterNode {
                    self.smoke = fParticles
                    self.smoke?.position = CGPoint(x: bomb.position.x, y: bomb.position.y)
                    self.addChild(self.smoke!)
                }
            }
            catch { }
            addChild(bomb)
        }
    }
    
    func removeBomb() {
        if selectedNode.name != nil {
            if selectedNode.action(forKey: "removing") == nil {
                let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                scaleAction.timingMode = .easeOut
                selectedNode.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                    withKey:"removing")
                bomb = nil
                selectedNode = SKSpriteNode()
                self.smoke?.removeFromParent()
            }
        }
    }
    
    // MARK: Touch events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: itemsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            if !level.isRockAtColumn(column, row: row) {
                if let item = level.itemAtColumn(column, row: row) {
                    
                    showSelectionIndicatorForItem(item)
                    swipeFromColumn = column
                    swipeFromRow = row
                }
            }
        }
        else {
            let touch = touches.first!
            let positionInScene = touch.location(in: self)
            
            selectNodeForTouch(positionInScene)
        }
    }
    
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if swipeFromColumn == nil {
            let touch = touches.first!
            let positionInScene = touch.location(in: self)
            let previousPosition = touch.previousLocation(in: self)
            let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
            
            panForTranslation(translation)
        }
        else {
            let touch = touches.first!
            let location = touch.location(in: itemsLayer)
            
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
    
    func trySwapHorizontal(_ horzDelta: Int, vertical vertDelta: Int) {
        // 1
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        // 2
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        // 3
        if !level.isRockAtColumn(toColumn, row: toRow) {
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        swipeFromColumn = nil
        swipeFromRow = nil
        
        if selectedNode.name != nil {
            
            let touch = touches.first!
            let location = touch.location(in: itemsLayer)
            
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func boundLayerPos(_ aNewPosition: CGPoint) -> CGPoint {
        let winSize = self.view!.frame.size
        var retval = aNewPosition
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(backgroundImg!.size.width) + winSize.width))
        retval.y = self.position.y
        
        return retval
    }
    
    func panForTranslation(_ translation: CGPoint) {
        let position = selectedNode.position
        
        if selectedNode.name == kMovableNodeName {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            smoke?.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        } else {
            let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            backgroundImg?.position = self.boundLayerPos(aNewPosition)
        }
    }
    
    func degToRad(_ degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * .pi)
    }
    
    func selectNodeForTouch(_ touchLocation: CGPoint) {
        
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                selectedNode = touchedNode as! SKSpriteNode
            }
        }
    }
}
