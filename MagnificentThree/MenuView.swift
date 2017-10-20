//
//  MenuView.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/19/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import UIKit
import SpriteKit

protocol MenuViewDelegate: class {
    func MenuViewOnArcade(_ view: MenuView)
    func MenuViewOnRocky(_ view: MenuView)
}

class MenuView: SKView {
    
    // MARK: Delegate
    
    weak var menuDelegate: MenuViewDelegate?
    
    // MARK: Audio
    
    let theme = SKAction.playSoundFileNamed("Mag3Theme.mp3", waitForCompletion: false)
    let clickSound = SKAction.playSoundFileNamed("gunshot.mp3", waitForCompletion: false)
    
    // MARK: Variables
    
    let pad: CGFloat = 30.0
    let tpad: CGFloat = 10.0
    let buttonH: CGFloat = 30.0
    let buttonW: CGFloat = 100.0
    
    fileprivate var cscene: SKScene?
    
    fileprivate var logoIv: UIImageView?,
                townIv: UIImageView?,
                town: SKSpriteNode?,
                hayParticle: SKEmitterNode?,
                arcadeBtn: UIButton?,
                rockyBtn: UIButton?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.backgroundColor = UIColor(patternImage: UIImage(named: "BgTile")!)
        //self.printFontNamesInSystem()
        
        logoIv = UIImageView(image: UIImage(named: "Logo"))
        logoIv?.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(logoIv!)
        
        cscene = SKScene(size: self.bounds.size)
        //scene.backgroundColor = UIColor.clearColor()
        //scene.scaleMode = .SKSceneScaleModeAspectFill
        
        self.fillBackground()
        
        townIv = UIImageView(image: UIImage(named: "BgTown"))
        townIv?.contentMode = UIViewContentMode.scaleToFill
        
        town = SKSpriteNode(imageNamed: "BgTown")
        cscene?.addChild(town!)
        
        
        let path = Bundle.main.path(forResource: "pfHay", ofType: "sks")
        hayParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as? SKEmitterNode
        hayParticle!.position = CGPoint(x: 8, y: 15)
        hayParticle!.zPosition = 100
        hayParticle!.name = "Hay"
        hayParticle!.targetNode = scene
        cscene?.addChild(hayParticle!)
        
        arcadeBtn = UIButton(frame: CGRect.zero)
        arcadeBtn?.setImage(UIImage(named: "Arcade"), for: UIControlState())
        arcadeBtn?.setImage(UIImage(named: "ArcadeOn"), for: .highlighted)
        arcadeBtn?.sizeToFit()
        arcadeBtn?.contentMode = .scaleAspectFit
        arcadeBtn?.addTarget(self, action: #selector(MenuView.onArcade(_:)), for: .touchUpInside)
        self.addSubview(arcadeBtn!)
        
        rockyBtn = UIButton(frame: CGRect.zero)
        rockyBtn?.setImage(UIImage(named: "Rocky"), for: UIControlState())
        rockyBtn?.setImage(UIImage(named: "RockyOn"), for: .highlighted)
        rockyBtn?.sizeToFit()
        rockyBtn?.contentMode = .scaleAspectFit
        rockyBtn?.addTarget(self, action: #selector(MenuView.onRocky(_:)), for: .touchUpInside)
        self.addSubview(rockyBtn!)
        
        self.presentScene(cscene)
        
        let seq = SKAction.sequence([theme, SKAction.wait(forDuration: 30.0)])
        let repeatAction = SKAction.repeatForever(seq)
        town?.run(repeatAction, withKey: "themeAction")
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
        
        logoIv?.frame = CGRect(x: pad, y: 0, width: w - pad * 2, height: logoIv!.frame.size.height)
        townIv?.frame = CGRect(x: -tpad, y: h - townIv!.frame.size.height + tpad, width: w + tpad * 2, height: townIv!.frame.size.height)
        town?.position = CGPoint(x: w/2, y: townIv!.frame.size.height/2)
        arcadeBtn?.frame = CGRect(x: w/2 - arcadeBtn!.frame.size.width/2, y: h/2 - arcadeBtn!.frame.size.height/2, width: arcadeBtn!.frame.size.width, height: arcadeBtn!.frame.size.height)
        rockyBtn?.frame = CGRect(x: w/2 - rockyBtn!.frame.size.width/2, y: arcadeBtn!.frame.maxY, width: rockyBtn!.frame.size.width, height: rockyBtn!.frame.size.height)
    }
    
    // MARK: Private methods
    
    fileprivate func fillBackground() {
        
        let tile = SKTexture(imageNamed: "BgTile")
        var totH: CGFloat = 0
        var totW: CGFloat = 0
        var i: Int = 0
        var j: Int = 0
        
        while totH < UIScreen.main.bounds.size.height + tile.size().height {
            
            if totW >= UIScreen.main.bounds.size.width {
                totW = 0
                i = 0
            }
            
            while totW < UIScreen.main.bounds.size.width + tile.size().width {
                let bg = SKSpriteNode(texture: tile)
                bg.zPosition = -100
                bg.position = CGPoint(x: CGFloat(i) * tile.size().width, y: CGFloat(j) * tile.size().height)
                cscene?.addChild(bg)
                i += 1
                totW += tile.size().width
            }
            
            j += 1
            totH += tile.size().height
        }
    }
    
    fileprivate func printFontNamesInSystem() {
        for family in UIFont.familyNames {
            print("*", family);
            
            for name in UIFont.fontNames(forFamilyName: family ) {
                print(name);
            }
        }
    }
    
    // MARK: Public methods
    
    func onArcade(_ sender: UIButton?) {
        cscene?.run(clickSound)
        menuDelegate?.MenuViewOnArcade(self)
    }
    
    func onRocky(_ sender: UIButton?) {
        cscene?.run(clickSound)
        menuDelegate?.MenuViewOnRocky(self)
    }
}
