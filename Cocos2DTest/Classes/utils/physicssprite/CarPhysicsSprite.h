//
//  CarPhysicsSprite.h
//  Cocos2DTest
//
//  Created by Andrew Poes on 11/6/12.
//  Copyright (c) 2012 AndyTheDesigner. All rights reserved.
//

#import "PhysicsSprite.h"

@interface CarPhysicsSprite : PhysicsSprite
{
    
}

- (b2Vec2) getLateralVelocity;
- (b2Vec2) getForwardVelocity;
- (void) updateFriction;

- (void) updateDrive:(float)velocity;
- (void)updateTurn:(float)velocity;

@end
