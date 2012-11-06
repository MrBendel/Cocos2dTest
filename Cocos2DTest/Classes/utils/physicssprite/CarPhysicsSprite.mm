//
//  CarPhysicsSprite.m
//  Cocos2DTest
//
//  Created by Andrew Poes on 11/6/12.
//  Copyright (c) 2012 AndyTheDesigner. All rights reserved.
//

#import "CarPhysicsSprite.h"

@implementation CarPhysicsSprite

/**
 *
 */
- (b2Vec2) getLateralVelocity {
    b2Vec2 currentRightNormal = body_->GetWorldVector( b2Vec2(1,0) );
    return b2Dot( currentRightNormal, body_->GetLinearVelocity() ) * currentRightNormal;
}

/**
 *
 */
- (b2Vec2) getForwardVelocity {
    b2Vec2 currentRightNormal = body_->GetWorldVector( b2Vec2(0,1) );
    return b2Dot( currentRightNormal, body_->GetLinearVelocity() ) * currentRightNormal;
}

/**
 *
 */
- (void) updateFriction {
    b2Vec2 impulse = body_->GetMass() * - [self getLateralVelocity];
    body_->ApplyLinearImpulse( impulse, body_->GetWorldCenter() );
    body_->ApplyAngularImpulse( 0.1f * body_->GetInertia() * -body_->GetAngularVelocity() );
    
    b2Vec2 currentForwardNormal = [self getForwardVelocity];
    float currentForwardSpeed = currentForwardNormal.Normalize();
    float dragForceMagnitude = -2 * currentForwardSpeed;
    body_->ApplyForce( dragForceMagnitude * currentForwardNormal, body_->GetWorldCenter() );

}

/**
 *
 */
- (void) updateDrive:(float)velocity {

    //find desired speed
    float desiredSpeed = 0;
    if (velocity > 0) {
        desiredSpeed = 100 * velocity;
    } else {
        desiredSpeed = 20 * velocity;
    }
    
    //find current speed in forward direction
    b2Vec2 currentForwardNormal = body_->GetWorldVector( b2Vec2(0,1) );
    float currentSpeed = b2Dot( [self getForwardVelocity], currentForwardNormal );
    
    //apply necessary force
    float force = 0;
    if ( desiredSpeed > currentSpeed )
        force = 150;
    else if ( desiredSpeed < currentSpeed )
        force = -150;
    else
        return;
    body_->ApplyForce( force * currentForwardNormal, body_->GetWorldCenter() );
}

/**
 *
 */
- (void)updateTurn:(float)velocity {
    float desiredTorque = velocity * 15;
    body_->ApplyTorque( desiredTorque );
}

@end
