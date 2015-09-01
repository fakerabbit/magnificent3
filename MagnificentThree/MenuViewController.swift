//
//  MenuViewController.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/19/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, MenuViewDelegate {
    
    // MARK: variables
    
    /*lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("Mag3Theme", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
        }()*/
    
    private var v: MenuView?
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        v = MenuView(frame: UIScreen.mainScreen().bounds)
        v?.delegate = self
        self.view = v!;
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
    
    // MARK: MenuViewDelegate methods
    
    func MenuViewOnArcade(view: MenuView) {
        var controller: GameViewController = GameViewController()
        let appDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDel.navController?.popViewControllerAnimated(false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
}