//
//  GameViewController.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/12/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // MARK: variables
    
    var scene: GameScene!
    var level: Level!
    
    var movesLeft = 0
    var score = 0
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        let skView: SKView = SKView(frame: UIScreen.mainScreen().bounds)
        skView.multipleTouchEnabled = false
        self.view = skView
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = SKSceneScaleMode.AspectFit
        
        // Present the scene.
        skView.presentScene(scene)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lvlNum = Int(arc4random_uniform(4))
        level = Level(filename: "Level_\(lvlNum)")
        scene.level = level
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        beginGame()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Public methods
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        shuffle()
    }
    
    func shuffle() {
        let newItems = level.shuffle()
        scene.addSpritesForItems(newItems)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
                self.decrementMoves()
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedItems(chains) {
            
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingItems(columns) {
                let columns = self.level.topUpItems()
                self.scene.animateNewItems(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        decrementMoves()
        view.userInteractionEnabled = true
    }
    
    func updateLabels() {
        scene.target?.text = String(format: "%ld", level.targetScore)
        scene.moves?.text = String(format: "%ld", movesLeft)
        scene.score?.text = String(format: "%ld", score)
    }
    
    func decrementMoves() {
        --movesLeft
        updateLabels()
        if score >= level.targetScore {
            onGameOver(true)
        } else if movesLeft == 0 {
            onGameOver(false)
        }
    }
    
    func onGameOver(victory: Bool) {
        scene.userInteractionEnabled = false
        var controller: GameOverController = GameOverController(victory: victory, score: score)
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
}
