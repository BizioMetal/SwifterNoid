//
//  GameScene.swift
//  Blocks
//
//  Created by Giordano Scalzo on 14/06/2014.
//  Copyright (c) 2014 Effective Code. All rights reserved.
//

import SpriteKit

enum BodyCategories: UInt32 {
   case ball = 0b1,  world = 0b10, brick = 0b100, paddle = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var paddle:SKNode!
    var ball:SKNode!
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = frame.size
        addChild(background)
    }
    
    func setupWorld(){
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsWorld.gravity = CGVector(dx:0, dy:0)
        self.physicsWorld.contactDelegate = self
        physicsBody!.friction = 0.0
    }
    
    func createBall() -> SKNode {
        let radius = CGFloat(20.0)
        
        let ball = SKSpriteNode(imageNamed: "ball.png")
        ball.size = CGSize(width: radius*2, height: radius*2)
        ball.position = CGPoint(x:50,y:50)
        ball.zPosition = 1
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ball.physicsBody!.dynamic            = true
        ball.physicsBody!.allowsRotation     = true
        ball.physicsBody!.restitution        = 1.0
        ball.physicsBody!.friction           = 0.0
        ball.physicsBody!.linearDamping      = 0.0
        ball.physicsBody!.categoryBitMask    = BodyCategories.ball.rawValue
        ball.physicsBody!.collisionBitMask   = BodyCategories.world.rawValue | BodyCategories.brick.rawValue | BodyCategories.paddle.rawValue
        ball.physicsBody!.contactTestBitMask = BodyCategories.world.rawValue | BodyCategories.brick.rawValue | BodyCategories.paddle.rawValue

        return ball
    }

    func createPaddle() -> SKNode {
        let side   = 120.0
        let paddle = SKShapeNode(rectOfSize: CGSize(width: side, height: side/3))
        paddle.fillColor = UIColor.blackColor()
        paddle.position = CGPoint(x: 500, y: 30 + side/3)
        paddle.zPosition = 2
        paddle.strokeColor = UIColor.yellowColor()

        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: side, height: side/3))
        paddle.physicsBody!.restitution        = 1
        paddle.physicsBody!.friction           = 0.0
        paddle.physicsBody!.dynamic            = false
        paddle.physicsBody!.categoryBitMask    = BodyCategories.paddle.rawValue
        paddle.physicsBody!.collisionBitMask   = BodyCategories.ball.rawValue
        paddle.physicsBody!.contactTestBitMask = BodyCategories.ball.rawValue
        return paddle
    }
    
    
    func setupBricks(){
        let numBricks = 12
        let brickSize = CGSize(width: frame.size.width/CGFloat(numBricks) - 10, height: 40)
        let rows      = 3
        let startY    = frame.size.height - CGFloat((rows+2) * Int(brickSize.height))
        
        var even = true
        for row in 0...rows {
            for i in 1...numBricks {
                let brick = createBrick(brickSize, index: i, y: (startY) + CGFloat(row) * (brickSize.height), even: even)
                addChild(brick)
            }
            even = !even
        }
    }
    
    func brickColor() -> UIColor {
        let color = arc4random()%6
        
        switch color {
        case 0:
            return UIColor.greenColor()
        case 1:
            return UIColor.yellowColor()
        case 2:
            return UIColor.blueColor()
        case 3:
            return UIColor.brownColor()
        case 4:
            return UIColor.orangeColor()
        default:
            return UIColor.redColor()
        }
    }
    
    func createBrick(size: CGSize, index: Int, y: CGFloat, even: Bool) -> SKNode {

        let brick = SKShapeNode(rectOfSize: size)
        brick.fillColor = brickColor()
        
        let x = even ? CGFloat(index) * size.width + size.height : CGFloat(index)*size.width

        brick.position  = CGPoint(x: Int(x), y: Int(y))
        brick.zPosition = 1
        
        brick.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        brick.physicsBody!.dynamic     = false
        brick.physicsBody!.restitution = 0.1
        brick.physicsBody!.friction    = 0.0

        brick.physicsBody!.categoryBitMask    = BodyCategories.brick.rawValue
        brick.physicsBody!.collisionBitMask   = BodyCategories.ball.rawValue
        brick.physicsBody!.contactTestBitMask = BodyCategories.ball.rawValue

        return brick
    }
    
    override func didMoveToView(view: SKView) {
        setupBackground()
        setupWorld()
        setupBricks()

        ball = createBall()
        addChild(ball)
        ball.physicsBody!.applyImpulse(CGVector(dx:10, dy:10))
        
        paddle = createPaddle()
        addChild(paddle)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch : AnyObject! = touches.first
        let location = touch.locationInNode(self)
        
        paddle.position.x = location.x
    }
    
    func brickFrom(contact: SKPhysicsContact) -> SKNode {
        if ( contact.bodyA.categoryBitMask & BodyCategories.brick.rawValue ) == BodyCategories.brick.rawValue {
           return contact.bodyA.node!
        }
        return contact.bodyB.node!
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if ( contact.bodyA.categoryBitMask & BodyCategories.brick.rawValue ) == BodyCategories.brick.rawValue ||
            ( contact.bodyB.categoryBitMask & BodyCategories.brick.rawValue ) == BodyCategories.brick.rawValue {
            let brick = brickFrom(contact)
                brick.removeFromParent()
                /*
                brick.runAction(SKAction.sequence(
                    [SKAction.scaleTo(1.5, duration:0.1),
                        SKAction.scaleTo(0.1, duration:0.3),
                        SKAction.runBlock({
                            brick.removeFromParent()
                            })
                        ]))
                */
        }
        
    }
    
    
}
