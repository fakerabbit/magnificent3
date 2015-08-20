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
    
    // MARK: Audio
    
    let theme = SKAction.playSoundFileNamed("Mag3Theme.mp3", waitForCompletion: false)
    
    // MARK: Variables
    
    let pad: CGFloat = 30.0
    let tpad: CGFloat = 10.0
    
    private var cscene: SKScene?
    private var logoIv: UIImageView?
    private var townIv: UIImageView?
    private var town: SKSpriteNode?
    private var hayParticle: SKEmitterNode?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.backgroundColor = UIColor(patternImage: UIImage(named: "BgTile")!)
        
        logoIv = UIImageView(image: UIImage(named: "Logo"))
        logoIv?.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(logoIv!)
        
        cscene = SKScene(size: self.bounds.size)
        //scene.backgroundColor = UIColor.clearColor()
        //scene.scaleMode = .SKSceneScaleModeAspectFill
        
        self.fillBackground()
        
        townIv = UIImageView(image: UIImage(named: "BgTown"))
        townIv?.contentMode = UIViewContentMode.ScaleToFill
        
        town = SKSpriteNode(imageNamed: "BgTown")
        cscene?.addChild(town!)
        
        
        var path = NSBundle.mainBundle().pathForResource("pfHay", ofType: "sks")
        hayParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as? SKEmitterNode
        hayParticle!.position = CGPointMake(5, 15)
        hayParticle!.zPosition = 100
        hayParticle!.name = "Hay"
        hayParticle!.targetNode = scene
        cscene?.addChild(hayParticle!)
        
        self.presentScene(cscene)
        
        let seq = SKAction.sequence([theme, SKAction.waitForDuration(30.0)])
        let repeatAction = SKAction.repeatActionForever(seq)
        town?.runAction(repeatAction, withKey: "themeAction")
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
        
        logoIv?.frame = CGRectMake(pad, 0, w - pad * 2, logoIv!.frame.size.height)
        townIv?.frame = CGRectMake(-tpad, h - townIv!.frame.size.height + tpad, w + tpad * 2, townIv!.frame.size.height)
        town?.position = CGPointMake(w/2, townIv!.frame.size.height/2)
    }
    
    // MARK: Private methods
    
    private func fillBackground() {
        
        let tile = SKTexture(imageNamed: "BgTile")
        var totH: CGFloat = 0
        var totW: CGFloat = 0
        var i: Int = 0
        var j: Int = 0
        
        while totH < UIScreen.mainScreen().bounds.size.height + tile.size().height {
            
            if totW >= UIScreen.mainScreen().bounds.size.width {
                totW = 0
                i = 0
            }
            
            while totW < UIScreen.mainScreen().bounds.size.width + tile.size().width {
                let bg = SKSpriteNode(texture: tile)
                bg.zPosition = -100
                bg.position = CGPointMake(CGFloat(i) * tile.size().width, CGFloat(j) * tile.size().height)
                cscene?.addChild(bg)
                i++
                totW += tile.size().width
            }
            
            j++
            totH += tile.size().height
        }
    }
}
