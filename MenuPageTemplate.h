//
//  MenuPageTemplate.h
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//  keny@eastcoastbands.com

#import <SpriteKit/SpriteKit.h>
#import "KRGameScroll.h"

@interface MenuPageTemplate : SKSpriteNode {
    
    SKScene * _scene;
    NSMutableSet *nodes;
    NSMutableSet *observers;
    
}

@property int identifier;

- (id) initFromScene:(SKScene*)scene page:(int)page;
- (void) removeObservers;

@end