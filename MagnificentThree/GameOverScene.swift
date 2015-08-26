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
    
    var sign: SKSpriteNode?
    var scoreCard: SKSpriteNode?
    
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
            scoreCard?.size = CGSizeMake(size.width - 20, scoreCard!.size.height/1.5)
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
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
