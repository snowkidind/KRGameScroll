//
//  AnotherScene.h
//  ScrollMe
//
//  Created by Keny Ruyter on 8/19/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//  keny@eastcoastbands.com

#import <SpriteKit/SpriteKit.h>

@interface AnotherScene : SKScene {
    NSMutableSet *nodes;
}
@property NSString* startLevel;

 - (void) begin;

@end
