//
//  TextureMapTest.h
//  Cocos2DTest
//
//  Created by Andrew Poes on 10/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@class CarPhysicsSprite;
@class BoxDebugLayer, GameLayer;
@class HKTMXTiledMap, HKTMXLayer;
@class SneakyJoystick, SneakyButton;

@interface TextureMapTest : CCLayer {
    CCNode *_tileLayer;
    
//    CCTMXTiledMap *_tileMap;
//    CCTMXLayer *_background;
    b2World *_world;				// strong ref
    BoxDebugLayer *_boxDebugLayer;
    GameLayer *_gameLayer;
    
    HKTMXTiledMap *_tileMap;
    HKTMXLayer *_background;
    
    CarPhysicsSprite *_player;
    
    SneakyJoystick *_leftJoystick;
	SneakyButton *_rightButton;
    
    CGFloat _targetScale;
    CGFloat _currentScale;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void)setViewpointCenter:(CGPoint) position;
- (void)setPlayerPosition:(CGPoint) position;
- (void)update:(ccTime)dt;

@end
