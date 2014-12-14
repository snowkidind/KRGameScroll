//
//  KRGameScroll.h
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//  keny@eastcoastbands.com

#import <SpriteKit/SpriteKit.h>

@interface KRGameScroll : SKNode {
    
    SKScene *_scene;
    BOOL isVertical;
    BOOL showNavBoxes;
    float startSwipe;
    float lastPosition;
    int currentScreen;
    int state;
    NSTimer *timer;
    NSMutableSet *observers;
    int minimumSlideLength;
    int minimumDragThreshold;
    
}

@property NSMutableArray *pages;

// call if you want a horizontal scroller
- (id) initWithScene:(SKScene*)scene;

// call if you want a vertical scroller
- (id) initWithScene:(SKScene*)scene vertical:(BOOL)vertical;

// command to attach the individual pages to the scroller from the designated index.
- (void) drawPagesAtIndex:(int)index;

// call to initialize the first time.
- (void) initialMoveToPage:(int)page;

// call whenever you want to go to a specific page
- (void) moveToPage:(int)page;

// call just before you destroy the scroller
- (void) cleanUpAfterSceneChange;

@end
