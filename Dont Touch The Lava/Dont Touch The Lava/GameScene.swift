//
//  GameScene.swift
//  Dont Touch The Lava
//
//  Created by Cormac Chester on 6/25/14.
//  Copyright (c) 2014 Extreme Images. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Physics
    let playerCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    
    //SKNodes
    let playerSprite = SKSpriteNode(imageNamed:"character@2x")
    let groundSprite = SKSpriteNode(imageNamed:"ground")
    
    var touchLoc = CGPoint()
    var isTouching = false
    var shouldJump = false
    var jumpCounter = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -4.0)
        self.physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        //Player
        playerSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        playerSprite.xScale = 2
        playerSprite.yScale = 2
        playerSprite.physicsBody = SKPhysicsBody(rectangleOfSize: playerSprite.size)
        playerSprite.physicsBody.dynamic = true
        playerSprite.physicsBody.categoryBitMask = playerCategory
        playerSprite.physicsBody.collisionBitMask = groundCategory
        playerSprite.physicsBody.contactTestBitMask = groundCategory
        
        groundSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:(CGRectGetMinY(self.frame)+137))
        groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundSprite.size)
        groundSprite.physicsBody.dynamic = false
        groundSprite.physicsBody.friction = 0
        groundSprite.physicsBody.categoryBitMask = groundCategory
        groundSprite.name = "ground"
        
        self.addChild(playerSprite)
        self.addChild(groundSprite)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        isTouching = true
        
        let touch:UITouch = touches.anyObject() as UITouch
        let location:CGPoint = touch.locationInNode(self)
        
        touchLoc = location
        
        let nodes:NSArray = nodesAtPoint(touch.locationInNode(self))
        for groundSprite : AnyObject in nodes
        {
            shouldJump = true
            if (jumpCounter < 2)
            {
                movePlayerY()
            }
        }
    }
   
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        isTouching = false
        shouldJump = false
        
    }
    
    func movePlayerX()
    {
        if (touchLoc.x < (CGRectGetMaxX(self.frame)/2))
        {
            var moveActionLeft = (SKAction.moveByX(-5, y: 0, duration: 0.1))
            playerSprite.runAction(moveActionLeft)
        }
        else if (touchLoc.x > (CGRectGetMaxX(self.frame)/2))
        {
            var moveActionRight = (SKAction.moveByX(5, y: 0, duration: 0.1))
            playerSprite.runAction(moveActionRight)
        }
    }
    
    func movePlayerY()
    {
        playerSprite.physicsBody.velocity = CGVectorMake(playerSprite.physicsBody.velocity.dx, 250)
        jumpCounter++
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
    
        if (contact.bodyA.categoryBitMask & groundCategory ) == groundCategory || ( contact.bodyB.categoryBitMask & groundCategory ) == groundCategory {
            //Player contacts groud
            jumpCounter = 0
        }
    
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if (isTouching)
        {
            if (!shouldJump)
            {
                movePlayerX()
            }
        }
    }

}
