//
//  GameScene.swift
//  Dont Touch The Lava
//
//  Created by Cormac Chester on 6/25/14.
//  Copyright (c) 2014 Extreme Images. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //SKNodes
    let playerSprite = SKSpriteNode(imageNamed:"character@2x")
    let groundSprite = SKSpriteNode(imageNamed:"ground")
    
    var touchLoc = CGPoint()
    var isTouching = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //self.physicsWorld.gravity = CGVectorMake(0.0, -1.0)
        //self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        //Player
        playerSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        playerSprite.xScale = 2
        playerSprite.yScale = 2
        playerSprite.physicsBody = SKPhysicsBody(rectangleOfSize: playerSprite.size)
        playerSprite.physicsBody.dynamic = true
        playerSprite.physicsBody.restitution = 0.4
        
        groundSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:(CGRectGetMinY(self.frame)+137))
        groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundSprite.size)
        groundSprite.physicsBody.dynamic = false
        groundSprite.name = "ground"
        
        self.addChild(playerSprite)
        self.addChild(groundSprite)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        isTouching = true
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            touchLoc = location

            if (location.y < 137)
            {
                playerJumpY()
            }
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            //self.addChild(sprite)
        }
    }
   
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        isTouching = false
        
    }
    
    func movePlayerX()
    {
        if (touchLoc.x < (CGRectGetMaxX(self.frame)/2))
        {
            //Send playerSprite left
            playerSprite.position.x -= 3
        }
        else if (touchLoc.x > (CGRectGetMaxX(self.frame)/2))
        {
            //Send playerSprite right
            playerSprite.position.x += 3
        }
    }
    
    func playerJumpY()
    {
        if (isTouching)
        {
            playerSprite.physicsBody.velocity.dy = 3
        }
        else
        {
            playerSprite.physicsBody.velocity.dy = 0
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        if (isTouching)
        {
            movePlayerX()
        }
        
    }
    

}
