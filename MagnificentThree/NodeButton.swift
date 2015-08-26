//
//  NodeButton.swift
//  MagnificentThree
//
//  Created by Mirko Justiniano on 8/25/15.
//  Copyright (c) 2015 MT. All rights reserved.
//

import SpriteKit

protocol NodeButtonDelegate:class {
    func NodeButtonDelegateOnTouch(button: NodeButton)
}

class NodeButton: SKSpriteNode {
    
    // MARK: delegate
    
    weak var delegate:NodeButtonDelegate?
    
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
    
    convenience init(normalImage: String, selectedImage: String, tag: Int) {
        
        let texture = SKTexture(imageNamed: normalImage)
        
        self.init(texture: texture, color: UIColor(), size: texture.size())
        
        self.userInteractionEnabled = true
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.tag = tag
    }
    
    // MARK: Touch Events
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.texture = SKTexture(imageNamed: selectedImage!)
        delegate?.NodeButtonDelegateOnTouch(self)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.texture = SKTexture(imageNamed: normalImage!)
    }
}
