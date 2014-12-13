//
//  MenuPageTemplate.h
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "KRGameScroll.h"

# define kNodeSelectDuration .15

@interface MenuPageTemplate : SKSpriteNode {
    
    SKScene * _scene;
    NSMutableSet *nodes;
    NSMutableSet *_observers;
    
}

@property int identifier;

- (id) initFromScene:(SKScene*)scene page:(int)page;
- (void) removeObservers;

@end