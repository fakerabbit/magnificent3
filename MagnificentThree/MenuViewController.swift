//
//  MenuViewController.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/19/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: variables
    
    private var v: MenuView?
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        v = MenuView(frame: UIScreen.mainScreen().bounds)
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
}