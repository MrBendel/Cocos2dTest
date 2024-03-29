/*
 *  GameLayer.mm
 *  TenFloorsDown
 *
 *  Created by Thomas Bruno on 4/5/12.
 *
 * Copyright (c) 2012 Thomas Bruno.
 * Copyright (c) 2012 NaveOSS.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "GameLayer.h"
#import "Constants.h"

@implementation GameLayer

/**
 * convert point to meters
 */
+ (b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

/**
 * convert to Cocos2d Point System
 */
+ (CGPoint)convertTileMapPolyPointsToCCPoints:(CGPoint)point {
	return ccp(point.x/CC_CONTENT_SCALE_FACTOR(),-point.y/CC_CONTENT_SCALE_FACTOR());
}

/**
 *
 */
- (void)processPolygonObjectGroup:(CCTMXObjectGroup*)group mapHeight:(int)mapHeight box2dWorld:(b2World*)world {
    for (NSMutableDictionary *waypoint in group.objects) {
       
        NSString *polygonPoints = [waypoint objectForKey:@"polygonPoints"];
        int x = [[waypoint objectForKey:@"x"] intValue];
        int y = [[waypoint objectForKey:@"y"] intValue];
        
        int width = [[waypoint objectForKey:@"width"] intValue];
        int height = [[waypoint objectForKey:@"height"] intValue];
        
        if (polygonPoints) { // polygon strip
            b2BodyDef screenBorderDef;
            screenBorderDef.position.Set(x/PTM_RATIO, y/PTM_RATIO);
            b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);            
            // Polyline points are separated by a space, get an array of each set of points.
            NSArray *points = [polygonPoints componentsSeparatedByString:@" "];
            
            b2ChainShape chain;
            int numPoints = [points count];
            b2Vec2 *vs = new b2Vec2[numPoints];
            for(int i=0; i < numPoints; ++i) {
                NSArray *thisPointArray = [[points objectAtIndex:i] componentsSeparatedByString: @","];
                CGPoint point = [GameLayer convertTileMapPolyPointsToCCPoints:ccp([[thisPointArray objectAtIndex:0] intValue],[[thisPointArray objectAtIndex:1] intValue])];
                b2Vec2 thisPoint = b2Vec2([GameLayer toMeters:point]);
                vs[i].Set(thisPoint.x,thisPoint.y);
            }
            chain.CreateChain(vs,numPoints);
            delete vs;
            b2FixtureDef chainDef;
            chainDef.shape = &chain;
            chainDef.density = 1.0f;
            chainDef.friction = 0.69f;
            chainDef.restitution = 0.0f;
            screenBorderBody->CreateFixture(&chainDef);
        } else if (width and height) { // box with defined width and height
            b2BodyDef screenBorderDef;
            screenBorderDef.position.Set((x+width/2)/PTM_RATIO, (y+height/2)/PTM_RATIO);            
            b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
            b2PolygonShape dynamicBox;
            dynamicBox.SetAsBox((width/CC_CONTENT_SCALE_FACTOR())/2/PTM_RATIO, (height/CC_CONTENT_SCALE_FACTOR())/2/PTM_RATIO);
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.69f;
            screenBorderBody->CreateFixture(&fixtureDef);
        } else { // default box, just x & y
            width = 20;
            height = 20;
            b2BodyDef screenBorderDef;
            screenBorderDef.position.Set(x/PTM_RATIO, y/PTM_RATIO);
            b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
            b2PolygonShape dynamicBox;
            dynamicBox.SetAsBox((width/CC_CONTENT_SCALE_FACTOR())/2/PTM_RATIO, (height/CC_CONTENT_SCALE_FACTOR())/2/PTM_RATIO);
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.69f;
            screenBorderBody->CreateFixture(&fixtureDef);
        }
    }
}

@end
