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
    let platformCategory: UInt32 = 1 << 1
    let groundCategory: UInt32 = 1 << 2
    
    //SKNodes
    let playerSprite = SKSpriteNode(imageNamed:"character@2x")
    var platformsNode:SKNode!
    var starterPlatformSprite = SKSpriteNode(imageNamed:"platform")
    let groundSprite = SKSpriteNode(imageNamed:"ground")
    
    //Platform Timer
    var lastSpawnTimeInterval = NSTimeInterval()
    var lastUpdateTimeInterval = NSTimeInterval()
    var platformSpeed = 4.0
    
    var touchLoc = CGPoint()
    var isTouching = false
    var shouldJump = false
    var isFirstPlatform = true
    var jumpCounter = 0
    
    var score = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Physics World
        self.physicsWorld.gravity = CGVectorMake(0.0, -4.0)
        self.physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        platformsNode = SKNode()
        
        //Add nodes to beginning of scene
        self.addChild(self.createStarterPlatform())
        self.addChild(self.createPlayer())
        self.addChild(platformsNode)
        self.addChild(self.createGround())
        
        
        var removerStartPlatTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("removeStarterPlatform"), userInfo: nil, repeats: false)
        
        
    }
    
    //Create Player
    func createPlayer() -> SKSpriteNode
    {
        playerSprite.position = CGPoint(x:starterPlatformSprite.position.x, y:(starterPlatformSprite.position.y + 3))
        playerSprite.xScale = 2
        playerSprite.yScale = 2
        playerSprite.physicsBody = SKPhysicsBody(rectangleOfSize: playerSprite.size)
        playerSprite.physicsBody.dynamic = true
        playerSprite.physicsBody.categoryBitMask = playerCategory
        playerSprite.physicsBody.collisionBitMask = groundCategory | platformCategory
        playerSprite.physicsBody.contactTestBitMask = groundCategory | platformCategory
        playerSprite.physicsBody.allowsRotation = false
        
        return playerSprite
    }
    
    func createStarterPlatform() -> SKSpriteNode
    {
        
        starterPlatformSprite.xScale = 0.5
        starterPlatformSprite.yScale = 0.5
        starterPlatformSprite.position = CGPoint(x: (starterPlatformSprite.size.width + 5), y: (self.frame.height*(2/3)))
        
        starterPlatformSprite.physicsBody = SKPhysicsBody(rectangleOfSize: starterPlatformSprite.size)
        starterPlatformSprite.physicsBody.dynamic = false;
        starterPlatformSprite.physicsBody.categoryBitMask = platformCategory;
        starterPlatformSprite.physicsBody.contactTestBitMask = playerCategory;
        starterPlatformSprite.physicsBody.collisionBitMask = 0;
        starterPlatformSprite.physicsBody.affectedByGravity = false;
        starterPlatformSprite.physicsBody.usesPreciseCollisionDetection = true;
        starterPlatformSprite.physicsBody.friction = 0.8;
        
        return starterPlatformSprite
    }
    
    func removeStarterPlatform()
    {
        starterPlatformSprite.removeFromParent()
    }
    
    
    //Create platform
    func createPlatform()
    {
        var platformSprite = SKSpriteNode(imageNamed:"platform")
        
        var minY:Int = Int((platformSprite.size.height/2) + 200)
        var maxY:Int = Int(((self.frame.size.height*(3/4)) - platformSprite.size.height))
        var rangeY:Int = maxY - minY
        var actualY: Int = (Int(rand()) % (rangeY)) + minY
        NSLog(String(actualY))
        
        platformSprite.xScale = 0.5
        platformSprite.yScale = 0.5
        var platPos = CGPoint(x: Int(self.frame.width + (platformSprite.size.width/2)), y: actualY)
        platformSprite.position = platPos
        platformsNode.addChild(platformSprite)
        
        //Platform physics
        platformSprite.physicsBody = SKPhysicsBody(rectangleOfSize: platformSprite.size)
        platformSprite.physicsBody.dynamic = false;
        platformSprite.physicsBody.categoryBitMask = platformCategory;
        platformSprite.physicsBody.contactTestBitMask = playerCategory;
        platformSprite.physicsBody.collisionBitMask = 0;
        platformSprite.physicsBody.affectedByGravity = false;
        platformSprite.physicsBody.usesPreciseCollisionDetection = true;
        platformSprite.physicsBody.friction = 0.8;

        var platformLocNew = CGPoint(x: Int(-platformSprite.size.width/2), y: actualY)
        var actionMove = SKAction.moveTo(platformLocNew, duration: platformSpeed)
        var actionMoveDone = SKAction.removeFromParent()
        var platformCross = SKAction.runBlock({
            NSLog("Platform passed by")
            self.score++
            })
        let platformActions = [actionMove, platformCross, actionMoveDone]
        platformSprite.runAction(SKAction.sequence(platformActions))
    }
    
    //Create Ground
    func createGround() -> SKSpriteNode
    {
        groundSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:(CGRectGetMinY(self.frame)+137))
        groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundSprite.size)
        groundSprite.physicsBody.dynamic = false
        groundSprite.physicsBody.friction = 0.8
        groundSprite.physicsBody.categoryBitMask = groundCategory
        
        return groundSprite
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
            //Move left
            //var moveActionLeft = (SKAction.moveByX(-5, y: 0, duration: 0.1))
            //playerSprite.runAction(moveActionLeft)
            playerSprite.physicsBody.velocity = CGVectorMake(-200, playerSprite.physicsBody.velocity.dy)
        }
        else if (touchLoc.x > (CGRectGetMaxX(self.frame)/2))
        {
            //Move right
            //var moveActionRight = (SKAction.moveByX(5, y: 0, duration: 0.1))
            //playerSprite.runAction(moveActionRight)
            playerSprite.physicsBody.velocity = CGVectorMake(200, playerSprite.physicsBody.velocity.dy)
        }
    }
    
    func movePlayerY()
    {
        playerSprite.physicsBody.velocity = CGVectorMake(playerSprite.physicsBody.velocity.dx, 350)
        jumpCounter++
    }
    
    //Collision Detection
    func didBeginContact(contact: SKPhysicsContact) {
        
        //Player contacts ground
        if (contact.bodyA.categoryBitMask & groundCategory ) == groundCategory || ( contact.bodyB.categoryBitMask & groundCategory ) == groundCategory {
            //jumpCounter = 0
        }
        
        if (contact.bodyA.categoryBitMask & platformCategory ) == platformCategory || ( contact.bodyB.categoryBitMask & platformCategory ) == platformCategory {
            jumpCounter = 0
            NSLog("Player collided with platform")
        }

        
    
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLast:CFTimeInterval)
    {
        //Platform Spawn Loop
        lastSpawnTimeInterval += timeSinceLast
        if (lastSpawnTimeInterval > 1.5)
        {
            lastSpawnTimeInterval = 0
            createPlatform()
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
        //Handle Time Delta
        var timeSinceLast: CFTimeInterval = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if (timeSinceLast > 1) //More than a second since last update
        {
            timeSinceLast = 1.0/60.0
            lastUpdateTimeInterval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLast)
        
        //Player X movement
        if (isTouching)
        {
            if (!shouldJump)
            {
                movePlayerX()
            }
        }
    }

}
