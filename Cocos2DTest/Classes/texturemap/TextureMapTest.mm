//
//  TextureMapTest.m
//  Cocos2DTest
//
//  Created by Andrew Poes on 10/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TextureMapTest.h"

#import "SneakyButton.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "SneakyButtonSkinnedBase.h"
#import "ColoredCircleSprite.h"

#import "HKTMXTiledMap.h"

@implementation TextureMapTest

/**
 * Helper class method that creates a Scene with the HelloWorldLayer as the only child.
 */
+ (CCScene *) scene {
	CCScene *scene = [CCScene node];
	TextureMapTest *layer = [TextureMapTest node];
	[scene addChild: layer];
	return scene;
}

/**
 * init func
 */
- (id)init {
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _tileLayer = [CCNode node];
        [self addChild:_tileLayer];
        
        NSString* pathToTileMap = [[NSBundle mainBundle] pathForResource:@"tmw_desert" ofType:@"tmx" inDirectory:@"data/tilemaps"];
        _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:pathToTileMap];
        _background = [_tileMap layerNamed:@"Background"];
        [_background updateScale:0.7];
        
        [_tileLayer addChild:_tileMap z:0];
        
        // get info for player center
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        
        CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:PNGPATH(@"Player")];
        _player = [CCSprite spriteWithTexture:t];
        [_player setPosition:ccp(x,y)];
        [_tileLayer addChild:_player z:1];
        
        [self setViewpointCenter:_player.position];
        
        SneakyJoystickSkinnedBase *leftJoy = [[SneakyJoystickSkinnedBase alloc] init];
		leftJoy.position = ccp(70,70);
		leftJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:64];
		leftJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:32];
		leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
		_leftJoystick = leftJoy.joystick;
		[self addChild:leftJoy];
		
		SneakyButtonSkinnedBase *rightBut = [[SneakyButtonSkinnedBase alloc] init];
		rightBut.position = ccp(winSize.width - 64,64);
		rightBut.defaultSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 255, 255, 128) radius:32];
		rightBut.activatedSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 255, 255, 255) radius:32];
		rightBut.pressSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 255) radius:32];
		rightBut.button = [[SneakyButton alloc] initWithRect:CGRectMake(0, 0, 64, 64)];
		_rightButton = rightBut.button;
		_rightButton.isToggleable = YES;
		[self addChild:rightBut];
        
        // enable touches
        [self setIsTouchEnabled:YES];
        
        _targetScale = 1.0f;
        _currentScale = 1.0f;
    }
    return self;
}

/**
 * do after view is loaded
 */
- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    [self schedule:@selector(update:) interval:1/60.f];
}
/**
 * register with touch dispatcher
 */
/*
- (void)registerWithTouchDispatcher {
    CCTouchDispatcher *ccTouchDispatcher = [[CCDirector sharedDirector] touchDispatcher];
	[ccTouchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
*/

/**
 * set the viewpoint to center on a position
 */
- (void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = position.x;// MAX(position.x, winSize.width / 2);
    int y = position.y;// MAX(position.y, winSize.height / 2);
//    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
//    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
//    viewPoint.x *= _currentScale;
//    viewPoint.y *= _currentScale;
    _tileLayer.position = viewPoint;
    
}

- (void)setPlayerPosition:(CGPoint) position {
    _player.position = position;
    [self setViewpointCenter:_player.position];
}

#pragma mark Update

- (void)update:(ccTime)dt {
    
    if (fabsf(_leftJoystick.velocity.x + _leftJoystick.velocity.y) > 0.0f) {
        CGPoint pos = _player.position;
        CGPoint vel = ccpMult(_leftJoystick.velocity, 20.0f);
        [self setPlayerPosition:ccp(pos.x + vel.x, pos.y + vel.y)];
        
        _targetScale = 0.7;
    } else {
        _targetScale = 1;
    }
    
    
    
    _currentScale += (_targetScale - _tileLayer.scale) * 0.05;
//    _tileLayer.scale = _currentScale;
}

#pragma mark Touches Lifecycle

/*
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    [self setPlayerPosition:touchLocation];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    [self setPlayerPosition:touchLocation];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    [self setPlayerPosition:touchLocation];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // do something, or not
}
 */


#pragma mark Dealloc

/**
 *
 */
- (void)dealloc {
    [_tileMap release];
    
    [super dealloc];
}

@end
