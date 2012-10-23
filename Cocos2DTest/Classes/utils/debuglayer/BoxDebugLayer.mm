//
//  BoxDebugLayer.m
//
//  Created by John Wordsworth on 12/06/2011.
//

#import "BoxDebugLayer.h"

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@implementation BoxDebugLayer

/** Create a debug layer with the given world and ptm ratio */
+(BoxDebugLayer *)debugLayerWithWorld:(b2World *)world ptmRatio:(int)ptmRatio 
{
    return [[[BoxDebugLayer alloc] initWithWorld:world ptmRatio:ptmRatio] autorelease];
}

/** Create a debug layer with the given world, ptm ratio and debug display flags */
+(BoxDebugLayer *)debugLayerWithWorld:(b2World *)world ptmRatio:(int)ptmRatio flags:(uint32)flags
{
    return [[[BoxDebugLayer alloc] initWithWorld:world ptmRatio:ptmRatio flags:flags] autorelease];
}

/** Create a debug layer with the given world and ptm ratio */
-(id)initWithWorld:(b2World*)world ptmRatio:(int)ptmRatio
{
    return [self initWithWorld:world ptmRatio:ptmRatio flags:b2Draw::e_shapeBit];
}

/** Create a debug layer with the given world, ptm ratio and debug display flags */
-(id)initWithWorld:(b2World*)world ptmRatio:(int)ptmRatio flags:(uint32)flags
{
	if ((self = [self init])) {
		_boxWorld = world;
        _ptmRatio = ptmRatio;
		_debugDraw = new GLESDebugDraw( ptmRatio );
        
		_boxWorld->SetDebugDraw(_debugDraw);
		_debugDraw->SetFlags(flags);		
	}
	
	return self;    
}

/** Clean up by deleting the debug draw layer. */
-(void)dealloc
{
	_boxWorld = NULL;
	
	if ( _debugDraw != NULL ) {
		delete _debugDraw;
	}
	
	[super dealloc];
}

/**
 * draw the view
 */
-(void)draw {
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
    _boxWorld->DrawDebugData();
}

@end
