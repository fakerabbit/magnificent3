//
//  GameOverController.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/24/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit
import SpriteKit

enum GameType: Printable {
    case Arcade
    case Rocky
    
    var description: String {
        switch self {
        case .Arcade: return "Arcade"
        case .Rocky: return "Rocky"
        }
    }
}

class GameOverController: UIViewController, NodeButtonDelegate {
    
    // MARK: variables
    
    var victory: Bool = false,
        score = 0,
        gameType: GameType = .Arcade
    
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
        let skView: SKView = SKView(frame: UIScreen.mainScreen().bounds)
        skView.multipleTouchEnabled = false
        self.view = skView
        
        // Create and configure the scene.
        scene = GameOverScene(size: skView.bounds.size, victory: victory, points: score)
        scene.scaleMode = SKSceneScaleMode.AspectFit
        scene.menu?.delegate = self
        scene.play?.delegate = self
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: NodeButtonDelegate methods
    
    func NodeButtonDelegateOnTouch(button: NodeButton) {
        scene?.playButton()
        if button.tag == 1 { // play
            scene.userInteractionEnabled = false
            var controller = UIViewController()
            if self.gameType == .Arcade {
                controller = GameViewController()
            }
            else if self.gameType == .Rocky {
                controller = RockyViewController()
            }
            let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
            appDel.navController?.popViewControllerAnimated(false)
            appDel.navController?.pushViewController(controller, animated: true)
            appDel.navController?.viewControllers = [controller]
        }
        else if button.tag == 2 { // menu
            scene.userInteractionEnabled = false
            var controller: MenuViewController = MenuViewController()
            let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
            appDel.navController?.popViewControllerAnimated(false)
            appDel.navController?.pushViewController(controller, animated: true)
            appDel.navController?.viewControllers = [controller]
        }
    }
}
