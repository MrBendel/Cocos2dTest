//
//  TextureMapTest.h
//  Cocos2DTest
//
//  Created by Andrew Poes on 10/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap, HKTMXLayer;
@class SneakyJoystick, SneakyButton;

@interface TextureMapTest : CCLayer {
    CCNode *_tileLayer;
    
//    CCTMXTiledMap *_tileMap;
//    CCTMXLayer *_background;
    
    HKTMXTiledMap *_tileMap;
    HKTMXLayer *_background;
    
    CCSprite *_player;
    
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