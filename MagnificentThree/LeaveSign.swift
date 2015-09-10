//
//  LeaveSign.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 9/9/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

protocol LeaveSignDelegate:class {
    func LeaveSignDelegateOnYes(button: LeaveSign)
    func LeaveSignDelegateOnNo(button: LeaveSign)
}

class LeaveSign: SKSpriteNode {
    
    // MARK: delegate
    
    weak var delegate:LeaveSignDelegate?
    
    // MARK: variables
    
    var normalImage: String?,
        selectedImage: String?,
        tag: Int = 0
    
    // MARK: Init
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(tag: Int) {
        
        let texture = SKTexture(imageNamed: "LeaveGame")
        self.init(texture: texture, color: UIColor(), size: texture.size())
        self.userInteractionEnabled = true
        self.scene?.scaleMode = .AspectFit
        self.tag = tag
        
        var leave = SKLabelNode(text: "YES")
        leave.fontName = "Sahara"
        leave.fontColor = UIColor.whiteColor()
        leave.fontSize = 24
        addChild(leave)
        leave.position = CGPointMake(0, -(leave.frame.size.height * 2))
        leave.userInteractionEnabled = false
        leave.name = "YES"
        
        var stay = SKLabelNode(text: "NO")
        stay.fontName = "Sahara"
        stay.fontColor = UIColor.whiteColor()
        stay.fontSize = 24
        addChild(stay)
        stay.position = CGPointMake(stay.frame.size.width * 4, -(stay.frame.size.height * 2))
        stay.userInteractionEnabled = false
        stay.name = "NO"
    }
    
    // MARK: Touch Events
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        let positionInScene = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        
        if touchedNode is SKLabelNode {
            if touchedNode.name == "YES" {
                delegate?.LeaveSignDelegateOnYes(self)
            }
            else if touchedNode.name == "NO" {
                delegate?.LeaveSignDelegateOnNo(self)
            }
        }
    }
}
