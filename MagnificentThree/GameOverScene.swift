//
//  GameOverScene.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/24/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    // MARK: Audio
    
    let clickSound = SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false),
        victorySound = SKAction.playSoundFileNamed("westerntune.mp3", waitForCompletion: false),
        defeatSound = SKAction.playSoundFileNamed("harmonica.mp3", waitForCompletion: false)
    
    // MARK: Variables
    
    var sign: SKSpriteNode?,
        scoreCard: SKSpriteNode?,
        maxCard: SKSpriteNode?,
        minCard: SKSpriteNode?
    
    var menu: NodeButton?,
        play: NodeButton?
    
    var score: SKLabelNode?,
        maxScoreLbl: SKLabelNode?,
        minScoreLbl: SKLabelNode?,
        maxScore: Int = 0,
        minScore: Int = 0,
        finalScore: Int = 0,
        victory: Bool = false
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    init(size: CGSize, victory: Bool, points: Int, type: GameType) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.victory = victory
        finalScore = points
        
        if victory {

            let background = SKSpriteNode(imageNamed: "BgGameVictory")
            addChild(background)
            
            sign = SKSpriteNode(imageNamed: "Victory")
            scoreCard = SKSpriteNode(imageNamed: "ScoreCard")
            scoreCard?.scene?.scaleMode = .aspectFit
            scoreCard?.position = CGPoint(x: 0, y: -scoreCard!.size.height)
            scoreCard?.size = CGSize(width: size.width - 25, height: scoreCard!.size.height)
            addChild(scoreCard!)
            
            score = SKLabelNode(text: "0")
            score?.fontName = "Sahara"
            score?.fontColor = UIColor.white
            score?.fontSize = 24
            scoreCard?.addChild(score!)
            score?.position = CGPoint(x: 0, y: -(scoreCard!.size.height/2 - score!.frame.size.height/1))
            
            maxScore = DataMgr.sharedInstance.highestScoreForGame(type)
            if maxScore > 0 {
                maxCard = SKSpriteNode(imageNamed: "MaxCard")
                maxCard?.scene?.scaleMode = .aspectFit
                maxCard?.position = CGPoint(x: 0, y: -maxCard!.size.height)
                maxCard?.size = CGSize(width: size.width - 25, height: maxCard!.size.height)
                addChild(maxCard!)
                
                maxScoreLbl = SKLabelNode(text: "0")
                maxScoreLbl?.fontName = "Sahara"
                maxScoreLbl?.fontColor = UIColor.white
                maxScoreLbl?.fontSize = 24
                maxCard?.addChild(maxScoreLbl!)
                maxScoreLbl?.position = CGPoint(x: 0, y: -(maxCard!.size.height/2 - maxScoreLbl!.frame.size.height/1))
            }
            //println("max score: \(maxScore)")
            
            minScore = DataMgr.sharedInstance.lowestScoreForGame(type)
            if minScore > 0 {
                minCard = SKSpriteNode(imageNamed: "LowCard")
                minCard?.scene?.scaleMode = .aspectFit
                minCard?.position = CGPoint(x: 0, y: -minCard!.size.height)
                minCard?.size = CGSize(width: size.width - 25, height: minCard!.size.height)
                addChild(minCard!)
                
                minScoreLbl = SKLabelNode(text: "0")
                minScoreLbl?.fontName = "Sahara"
                minScoreLbl?.fontColor = UIColor.white
                minScoreLbl?.fontSize = 24
                minCard?.addChild(minScoreLbl!)
                minScoreLbl?.position = CGPoint(x: 0, y: -(minCard!.size.height/2 - minScoreLbl!.frame.size.height/1))
            }
            //println("min score: \(minScore)")
        }
        else {
            let background = SKSpriteNode(imageNamed: "BgGameOver")
            addChild(background)
            
            sign = SKSpriteNode(imageNamed: "Defeat")
            scoreCard = SKSpriteNode()
        }
        
        sign?.position = CGPoint(x: 0, y: size.height/1)
        sign?.size = CGSize(width: size.width, height: sign!.size.height)
        addChild(sign!)
        
        menu = NodeButton(normalImage: "Menu", selectedImage: "MenuOn", tag: 2)
        menu?.position = CGPoint(x: size.width/4, y: -size.height)
        addChild(menu!)
        
        play = NodeButton(normalImage: "Play", selectedImage: "PlayOn", tag: 1)
        play?.position = CGPoint(x: -size.width/4, y: -size.height)
        addChild(play!)
    }
    
    // MARK: Scene methods
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        /*let blockAction = SKAction.runBlock { () -> Void in
            self.initialScore += 1
            self.score?.text = String(self.initialScore)
        }
        
        let waitAction = SKAction.waitForDuration(0)
        let wholeAction = SKAction.sequence([waitAction, blockAction])
        let increaseAction = SKAction.repeatAction(wholeAction, count: self.finalScore)*/
        
        if self.victory {
            self.run(victorySound)
        }
        else {
            self.run(defeatSound)
        }
        
        let Duration: TimeInterval = 0.3
        let moveA = SKAction.move(to: CGPoint(x: 0, y: size.height/3), duration: Duration)
        moveA.timingMode = .easeOut
        sign?.run(moveA)
        
        let moveB = SKAction.move(to: CGPoint(x: 0, y: size.height/3 - (scoreCard!.size.height/2 + sign!.size.height/2)), duration: 0.5)
        moveB.timingMode = .easeOut
        scoreCard?.run(moveB, completion: { () -> Void in
            //self.runAction(increaseAction)
            self.score?.text = String(self.finalScore)
        })
        
        let moveC = SKAction.move(to: CGPoint(x: size.width/4, y: -(size.height/2 - menu!.size.height/2)), duration: Duration)
        moveC.timingMode = .easeOut
        menu?.run(moveC)
        
        let moveD = SKAction.move(to: CGPoint(x: -size.width/4, y: -(size.height/2 - play!.size.height/2)), duration: Duration)
        moveD.timingMode = .easeOut
        play?.run(moveD)
        
        if maxCard != nil {
            
            let move = SKAction.move(to: CGPoint(x: 0, y: scoreCard!.position.y + scoreCard!.size.height/2), duration: 0.5)
            move.timingMode = .easeOut
            maxCard!.run(move, completion: { () -> Void in
                self.maxScoreLbl?.text = String(self.maxScore)
                
                if self.minCard != nil {
                    
                    let move = SKAction.move(to: CGPoint(x: 0, y: self.maxCard!.position.y - self.maxCard!.size.height), duration: 0.5)
                    move.timingMode = .easeOut
                    self.minCard!.run(move, completion: { () -> Void in
                        self.minScoreLbl?.text = String(self.minScore)
                    })
                }
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Public methods
    
    func playButton() {
        self.run(clickSound)
    }
}
