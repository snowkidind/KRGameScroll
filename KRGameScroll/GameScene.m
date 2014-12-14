//
//  GameScene.m
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//  keny@eastcoastbands.com

#import "GameScene.h"
#import "KRGameScroll.h"
#import "MenuPageTemplate.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {

    [self registerObservers];
    
    // this default will alternate every time you load the game scene. see AnotherScene.m
    BOOL vertical = [[NSUserDefaults standardUserDefaults] boolForKey:@"verticalScroll"];
    KRGameScroll *scrollMenu = [[KRGameScroll alloc] initWithScene:self vertical:vertical];
    
    // If you choose not to use vertical scroll this works too
    // KRGameScroll *scrollMenu = [[KRGameScroll alloc] initWithScene:self];
  
    // here we make menu pages and add them to the stack
    MenuPageTemplate *menuPage = [[MenuPageTemplate alloc] initFromScene:self page:1];
    [scrollMenu.pages addObject:menuPage];
    
    MenuPageTemplate *menuPage2 = [[MenuPageTemplate alloc] initFromScene:self page:2];
    [scrollMenu.pages addObject:menuPage2];
    
    MenuPageTemplate *menuPage3 = [[MenuPageTemplate alloc] initFromScene:self page:3];
    [scrollMenu.pages addObject:menuPage3];
    
    MenuPageTemplate *menuPage4 = [[MenuPageTemplate alloc] initFromScene:self page:4];
    [scrollMenu.pages addObject:menuPage4];
    
    [scrollMenu drawPagesAtIndex:1]; // place at starting index
    
    // if we are starting the program from install, index is set in App Delegate
    // index auto scrolls to last selected page.
    int scrollPage = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"scrollPage"];
    [scrollMenu initialMoveToPage:scrollPage]; // animate to selected position.
    
    [self addChild:scrollMenu];
}

- (void) loadExternalPage {
    NSLog(@"loadExternalPage");
}

- (void) registerObservers {
    self ->observers = [NSMutableSet set];
    __weak __typeof(self) weaklyNotifiedSelf = self;
    
    id ob = [[NSNotificationCenter defaultCenter] addObserverForName:@"loadExternalPage" object:nil queue:nil usingBlock:^(NSNotification *n) {
        [weaklyNotifiedSelf loadExternalPage];
    }];
    [observers addObject:ob];
}

- (void) removeObservers {
    for (id ob in observers){
        [[NSNotificationCenter defaultCenter] removeObserver:ob];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}



@end
