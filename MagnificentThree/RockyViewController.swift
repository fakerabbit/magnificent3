//
//  RockyViewController.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 9/4/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit
import SpriteKit

class RockyViewController: UIViewController, NodeButtonDelegate, LeaveSignDelegate {
    
    // MARK: Audio
    
    let shuffleSound = SKAction.playSoundFileNamed("banjo.mp3", waitForCompletion: false)
    
    // MARK: variables
    
    var scene: RockyScene!
    var level: Level!
    
    var movesLeft = 0
    var score = 0
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        let skView: SKView = SKView(frame: UIScreen.main.bounds)
        skView.isMultipleTouchEnabled = false
        self.view = skView
        
        // Create and configure the scene.
        scene = RockyScene(size: skView.bounds.size)
        scene.scaleMode = SKSceneScaleMode.aspectFit
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //level = Level(filename: "RLevel_17")
        let lvlNum = Int(arc4random_uniform(18))
        level = Level(filename: "RLevel_\(lvlNum)")
        scene.level = level
        scene.menu?.delegate = self
        scene.addTiles()
        scene.swipeHandler = {[unowned self]
            (swap:Swap) in
            self.handleSwipe(swap)
        }
        scene.bombHandler = {[unowned self]
            (type:ItemType) in
            self.handleBomb(type)
        }
        beginGame()
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.allButUpsideDown.rawValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Public methods
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        shuffle()
        let rockItems = level.rockItems()
        scene.addSpritesForRocks(rockItems)
    }
    
    func shuffle() {
        scene.removeAllCookieSprites()
        let newItems = level.shuffle()
        scene.addSpritesForItems(newItems)
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
                self.decrementMoves()
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        let itemsToRemove = level.itemsToRemove
        level.itemsToRemove.removeAll(keepingCapacity: false)
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedItems(chains) {
            
            self.scene.makeSureItemsAreRemoved(itemsToRemove)
            
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
    
    func handleBomb(_ type: ItemType) {
        view.isUserInteractionEnabled = false
        let chains = level.removeBombedItems(type)
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        scene.removeBomb()
        scene.animateMatchedItems(chains) {
            self.scene.makeSureItemsAreRemoved([])
            
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
        let swaps = level.detectPossibleSwaps()
        decrementMoves()
        if swaps.count == 0 {
            self.shuffle()
        }
        view.isUserInteractionEnabled = true
    }
    
    func updateLabels() {
        scene.target?.text = String(format: "%ld", level.targetScore)
        scene.moves?.text = String(format: "%ld", movesLeft)
        scene.score?.text = String(format: "%ld", score)
    }
    
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        if level.targetScore == 0 {
            while movesLeft > 0 {
                movesLeft -= 1
                self.score += 100
                updateLabels()
            }
            onGameOver(true)
        } else if movesLeft == 0 {
            onGameOver(false)
        }
    }
    
    func onGameOver(_ victory: Bool) {
        scene.isUserInteractionEnabled = false
        
        // Save game record
        if victory {
            DataMgr.sharedInstance.storeGame(.rocky, score: score)
        }
        
        // Show game over controller
        let controller: GameOverController = GameOverController(victory: victory, score: score, type: .rocky)
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.navController?.popViewController(animated: false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
    
    func showLeaveSign() {
        scene.showLeaveSign()
        scene.leaveSign?.delegate = self
    }
    
    func hideLeaveSign() {
        scene.hideLeaveSign()
    }
    
    func leaveGame() {
        scene.isUserInteractionEnabled = false
        let controller: MenuViewController = MenuViewController()
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.navController?.popViewController(animated: false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
    
    // MARK: NodeButtonDelegate methods
    
    func NodeButtonDelegateOnTouch(_ button: NodeButton) {
        
        if button.tag == 1 {
            showLeaveSign()
        }
    }
    
    // MARK: LeaveSignDelegate delegate
    
    func LeaveSignDelegateOnYes(_ button: LeaveSign) {
        leaveGame()
    }
    
    func LeaveSignDelegateOnNo(_ button: LeaveSign) {
        hideLeaveSign()
    }
}
