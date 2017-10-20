//
//  GameOverController.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/24/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverController: UIViewController, NodeButtonDelegate {
    
    // MARK: variables
    
    var victory: Bool = false,
        score = 0,
        gameType: GameType = .arcade
    
    var scene: GameOverScene!
    
    // MARK: Init
    
    init(victory: Bool, score: Int, type: GameType) {
        super.init(nibName: nil, bundle: nil)
        self.victory = victory
        self.score = score
        self.gameType = type
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        let skView: SKView = SKView(frame: UIScreen.main.bounds)
        skView.isMultipleTouchEnabled = false
        self.view = skView
        
        // Create and configure the scene.
        scene = GameOverScene(size: skView.bounds.size, victory: victory, points: score, type: gameType)
        scene.scaleMode = SKSceneScaleMode.aspectFit
        scene.menu?.delegate = self
        scene.play?.delegate = self
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: NodeButtonDelegate methods
    
    func NodeButtonDelegateOnTouch(_ button: NodeButton) {
        scene?.playButton()
        if button.tag == 1 { // play
            scene.isUserInteractionEnabled = false
            var controller = UIViewController()
            if self.gameType == .arcade {
                controller = GameViewController()
            }
            else if self.gameType == .rocky {
                controller = RockyViewController()
            }
            let appDel = UIApplication.shared.delegate! as! AppDelegate
            appDel.navController?.popViewController(animated: false)
            appDel.navController?.pushViewController(controller, animated: true)
            appDel.navController?.viewControllers = [controller]
        }
        else if button.tag == 2 { // menu
            scene.isUserInteractionEnabled = false
            let controller: MenuViewController = MenuViewController()
            let appDel = UIApplication.shared.delegate! as! AppDelegate
            appDel.navController?.popViewController(animated: false)
            appDel.navController?.pushViewController(controller, animated: true)
            appDel.navController?.viewControllers = [controller]
        }
    }
}
