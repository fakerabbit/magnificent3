//
//  MenuView.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/19/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit
import SpriteKit

class MenuView: SKView {
    
    // MARK: Variables
    
    let pad: CGFloat = 30.0
    let tpad: CGFloat = 10.0
    
    private var logoIv: UIImageView?
    private var townIv: UIImageView?
    private var town: SKSpriteNode?
    private var hayParticle: SKEmitterNode?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(patternImage: UIImage(named: "BgTile")!)
        
        logoIv = UIImageView(image: UIImage(named: "Logo"))
        logoIv?.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(logoIv!)
        
        var scene: SKScene = SKScene(size: self.bounds.size)
        scene.backgroundColor = UIColor.clearColor()
        //scene.scaleMode = .SKSceneScaleModeAspectFill
        
        townIv = UIImageView(image: UIImage(named: "BgTown"))
        townIv?.contentMode = UIViewContentMode.ScaleToFill
        
        town = SKSpriteNode(imageNamed: "BgTown")
        scene.addChild(town!)
        
        
        var path = NSBundle.mainBundle().pathForResource("pfHay", ofType: "sks")
        hayParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as? SKEmitterNode
        hayParticle!.position = CGPointMake(5, 15)
        hayParticle!.zPosition = 100
        hayParticle!.name = "Hay"
        hayParticle!.targetNode = scene
        scene.addChild(hayParticle!)
        
        self.presentScene(scene)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = self.frame.size.width,
        h = self.frame.size.height
        
        if w <= 0 || h <= 0 {
            return
        }
        
        logoIv?.frame = CGRectMake(pad, 20, w - pad * 2, logoIv!.frame.size.height)
        townIv?.frame = CGRectMake(-tpad, h - townIv!.frame.size.height + tpad, w + tpad * 2, townIv!.frame.size.height)
        town?.position = CGPointMake(w/2, townIv!.frame.size.height/2)
    }
}
