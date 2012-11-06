
//
//  TextureMapTest.m
//  Cocos2DTest
//
//  Created by Andrew Poes on 10/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TextureMapTest.h"

#import "AppDelegate.h"
#import "Constants.h"
#import "PhysicsSprite.h"
#import "BoxDebugLayer.h"
#import "GameLayer.h"

#import "SneakyButton.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "SneakyButtonSkinnedBase.h"
#import "ColoredCircleSprite.h"

#import "HKTMXTiledMap.h"

#pragma mark - TextureMapTest

@interface TextureMapTest (Private)
-(void) initPhysics;
-(PhysicsSprite*) createNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation TextureMapTest

/**
 * Helper class method that creates a Scene
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
        
        // init physics
        [self initPhysics];
        
        _tileLayer = [CCNode node];
        [self addChild:_tileLayer];
        
        NSString* pathToTileMap = [[NSBundle mainBundle] pathForResource:@"tmw_desert" ofType:@"tmx" inDirectory:@"data/tilemaps"];
                
        // create tile map
        _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:pathToTileMap];
        _background = [_tileMap layerNamed:@"Background"];
        [_background updateScale:0.7];
        
        [_tileLayer addChild:_tileMap z:0];
        [_tileLayer addChild:_boxDebugLayer z:1];
        
        // create game layer
        _gameLayer = [[GameLayer alloc] init];
        [_gameLayer processPolygonObjectGroup:[_tileMap objectGroupNamed:@"Collision"] mapHeight:_tileMap.mapSize.height box2dWorld:_world];
        
        // get info for player center
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        
        _player = [self createNewSpriteAtPosition:ccp(x,y)];
        [_tileLayer addChild:_player];
        
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
    
    [self scheduleUpdate];
    
//    CGSize s = [[CCDirector sharedDirector] winSize];
//    [self createNewSpriteAtPosition:ccp(s.width/2, s.height/2)];
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
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
//    viewPoint.x *= _currentScale;
//    viewPoint.y *= _currentScale;
    _tileLayer.position = viewPoint;
    
}

- (void)setPlayerPosition:(CGPoint) position {
    _player.position = ccp(position.x, position.y);
    [self setViewpointCenter:_player.position];
}

#pragma mark Private Methods

/**
 *
 */
-(void) initPhysics {
	
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	_world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	_world->SetAllowSleeping(true);
	
	_world->SetContinuousPhysics(true);
	
    uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
    
    _boxDebugLayer = [[BoxDebugLayer alloc] initWithWorld:_world ptmRatio:PTM_RATIO flags:flags];
}

/**
 *
 */
-(PhysicsSprite*) createNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
    
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:PNGPATH(@"Player")];
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:t rect:CGRectMake(0, 0, t.pixelsWide, t.pixelsHigh)];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics _world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = _world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
    
    return sprite;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self createNewSpriteAtPosition: location];
	}
}

#pragma mark Update Cycles

/**
 *
 */
-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the _world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);
    
    // ------ ------ ------ ------ ------ ------ ------ ------
    // joystick updates
    if (fabsf(_leftJoystick.velocity.x + _leftJoystick.velocity.y) > 0.0f) {
        CGPoint pos = _player.position;
        CGPoint vel = ccpMult(_leftJoystick.velocity, 20.0f);
        [self setPlayerPosition:ccp(pos.x + vel.x, pos.y + vel.y)];
        
        _targetScale = 0.7;
    } else {
        _targetScale = 1;
    }
    
    _currentScale += (_targetScale - _tileLayer.scale) * 0.05;
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
    
    delete _world;
	_world = NULL;
    
    [_boxDebugLayer release];
    
    [super dealloc];
}

@end
