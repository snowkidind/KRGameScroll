//
//  KRGameScroll.h
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface KRGameScroll : SKNode {
    
    SKScene *_scene;
    BOOL isVertical;
    float startSwipe_;
    float lastPosition_;
    int currentScreen_;
    int totalScreens_;
    float offsetLoc;
    // Internal state of scrollLayer (scrolling or idle).
    int state_;
    
    // Distance user must slide finger to start scrolling menu.
    int minimumTouchLengthToSlide_;
    
    // Distance user must slide finger to change the page.
    int minimumTouchLengthToChangePage_;
    
    // cleanup timer to allow transition effects
    NSTimer *timer;
    
    NSMutableSet *_observers;
}

@property NSMutableArray *pages;
@property(readwrite, assign) int minimumTouchLengthToSlide;
@property(readwrite, assign) int minimumTouchLengthToChangePage;

- (id)initWithScene:(SKScene*)scene;
- (id)initWithScene:(SKScene*)scene vertical:(BOOL)vertical;
- (void) drawPagesAtIndex:(int)index;
- (void) initialMoveToPage:(int)page;
- (void) moveToPage:(int)page;
- (void) cleanUpAfterSceneChange;

@end
