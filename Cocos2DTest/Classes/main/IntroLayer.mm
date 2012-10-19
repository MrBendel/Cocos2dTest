//
//  IntroLayer.m
//  Cocos2DTest
//
//  Created by Andrew Poes on 10/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "TextureMapTest.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

/**
* Helper class method that creates a Scene with the IntroLayer as the only child.
 */
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	IntroLayer *layer = [IntroLayer node];
	[scene addChild: layer];
	return scene;
}

/**
 *
 */
-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default.png"];
//		background.rotation = 90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Portrait~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:0];
    
    [self preloadData];
}

/**
 *
 */
-(void) makeTransition:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[TextureMapTest scene] withColor:ccWHITE]];
}

/**
 *
 */
- (void)preloadData {
    [[CCTextureCache sharedTextureCache] addImage:PNGPATH(@"Player")];
    
        /*
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
        [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        
        [[CCTextureCache sharedTextureCache] addImage:@"enemylaser1.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"enemypulse1.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"longsmoke.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"macgun1.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"napalmmissile.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"particle.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"shortsmoke.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bigbang.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"smallmissile.plist"];
        
        [[CCTextureCache sharedTextureCache] addImage:@"chopter.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"choptergatling.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"egmixer.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"gashiing.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"mantaray.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"poseidon.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lightningIX.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lightningVIII.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"owlion.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"owlionlaser.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"owlionleader.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"owlionmissile.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"owlionnapalm.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scroop.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LightningBird.plist"];
        
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"Man_Or_Machine_Gorillas.mp3"];
         */
}

@end
