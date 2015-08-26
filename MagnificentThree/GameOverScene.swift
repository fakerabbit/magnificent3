//
//  GameOverScene.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/24/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    // MARK: Variables
    
    var sign: SKSpriteNode?,
        scoreCard: SKSpriteNode?
    
    var menu: NodeButton?,
        play: NodeButton?
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, victory: Bool) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        if victory {
            let background = SKSpriteNode(imageNamed: "BgGameVictory")
            addChild(background)
            
            sign = SKSpriteNode(imageNamed: "Victory")
            scoreCard = SKSpriteNode(imageNamed: "ScoreCard")
            scoreCard?.scene?.scaleMode = .AspectFit
            scoreCard?.position = CGPointMake(0, -scoreCard!.size.height)
            scoreCard?.size = CGSizeMake(size.width - 25, scoreCard!.size.height/1.5)
            addChild(scoreCard!)
        }
        else {
            let background = SKSpriteNode(imageNamed: "BgGameOver")
            addChild(background)
            
            sign = SKSpriteNode(imageNamed: "Defeat")
        }
        
        sign?.position = CGPointMake(0, size.height/1)
        sign?.size = CGSizeMake(size.width, sign!.size.height)
        addChild(sign!)
        
        menu = NodeButton(normalImage: "Menu", selectedImage: "MenuOn", tag: 2)
        menu?.position = CGPointMake(size.width/4, -size.height)
        addChild(menu!)
        
        play = NodeButton(normalImage: "Play", selectedImage: "PlayOn", tag: 1)
        play?.position = CGPointMake(-size.width/4, -size.height)
        addChild(play!)
    }
    
    // MARK: Scene methods
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let Duration: NSTimeInterval = 0.3
        let moveA = SKAction.moveTo(CGPointMake(0, size.height/3), duration: Duration)
        moveA.timingMode = .EaseOut
        sign?.runAction(moveA)
        
        let moveB = SKAction.moveTo(CGPointMake(0, size.height/3 - (scoreCard!.size.height/2 + sign!.size.height/2)), duration: 0.5)
        moveB.timingMode = .EaseOut
        scoreCard?.runAction(moveB)
        
        let moveC = SKAction.moveTo(CGPointMake(size.width/4, -(size.height/2 - menu!.size.height/2)), duration: Duration)
        moveC.timingMode = .EaseOut
        menu?.runAction(moveC)
        
        let moveD = SKAction.moveTo(CGPointMake(-size.width/4, -(size.height/2 - play!.size.height/2)), duration: Duration)
        moveD.timingMode = .EaseOut
        play?.runAction(moveD)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
