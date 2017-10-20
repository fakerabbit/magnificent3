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
    
    fileprivate var v: MenuView?
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        v = MenuView(frame: UIScreen.main.bounds)
        v?.menuDelegate = self
        self.view = v!;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(Int(UIInterfaceOrientationMask.allButUpsideDown.rawValue)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: MenuViewDelegate methods
    
    func MenuViewOnArcade(_ view: MenuView) {
        let controller: GameViewController = GameViewController()
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.navController?.popViewController(animated: false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
    
    func MenuViewOnRocky(_ view: MenuView) {
        let controller: RockyViewController = RockyViewController()
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.navController?.popViewController(animated: false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
}
