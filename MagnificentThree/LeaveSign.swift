//
//  LeaveSign.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 9/9/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

protocol LeaveSignDelegate: AnyObject {
    func LeaveSignDelegateOnYes(_ button: LeaveSign)
    func LeaveSignDelegateOnNo(_ button: LeaveSign)
}

class LeaveSign: SKSpriteNode {
    
    // MARK: delegate
    
    weak var delegate:LeaveSignDelegate?
    
    // MARK: variables
    
    var normalImage: String?,
        selectedImage: String?,
        tag: Int = 0
    
    // MARK: Init
    
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(tag: Int) {
        
        let texture = SKTexture(imageNamed: "LeaveGame")
        self.init(texture: texture, color: UIColor(), size: texture.size())
        self.isUserInteractionEnabled = true
        self.scene?.scaleMode = .aspectFit
        self.tag = tag
        
        let leave = SKLabelNode(text: "YES")
        leave.fontName = "Sahara"
        leave.fontColor = UIColor.white
        leave.fontSize = 24
        addChild(leave)
        leave.position = CGPoint(x: 0, y: -(leave.frame.size.height * 2))
        leave.isUserInteractionEnabled = false
        leave.name = "YES"
        
        let stay = SKLabelNode(text: "NO")
        stay.fontName = "Sahara"
        stay.fontColor = UIColor.white
        stay.fontSize = 24
        addChild(stay)
        stay.position = CGPoint(x: stay.frame.size.width * 4, y: -(stay.frame.size.height * 2))
        stay.isUserInteractionEnabled = false
        stay.name = "NO"
    }
    
    // MARK: Touch Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
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
