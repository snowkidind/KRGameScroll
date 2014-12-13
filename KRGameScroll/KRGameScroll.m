//
//  KRGameScroll.m
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//

#import "KRGameScroll.h"
#import "MenuPageTemplate.h"

enum
{
    kScrollLayerStateIdle,
    kScrollLayerStateSliding,
};

#define kShortDragDuration .10
#define kLongDragDuration .25

@implementation KRGameScroll

@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize minimumTouchLengthToChangePage = minimumTouchLengthToChangePage_;

- (id)initWithScene:(SKScene*)scene
{
    self = [super init];
    if (self) {
        
        self.pages = nil;
        _scene = scene;
        isVertical = NO;
        
        [self prepareScroller];
        
    }
    return self;
}

- (id)initWithScene:(SKScene*)scene vertical:(BOOL)vertical {
    
    self = [super init];
    if (self) {
        
        self.pages = nil;
        _scene = scene;
        
        if (vertical) isVertical = YES;
        
        [self prepareScroller];
        
    }
    return self;
}

- (void) prepareScroller {
    
    // Scroll Window will disseminate touch information to pages contained
    self.userInteractionEnabled = YES;
    
    _pages = [NSMutableArray arrayWithObjects:nil];
    
    minimumTouchLengthToSlide_ = 5;
    minimumTouchLengthToChangePage_ = 20;
    currentScreen_ = 1;
    
    self ->_observers = [NSMutableSet set];
    __weak __typeof(self) weaklyNotifiedSelf = self;
    
    id ob = [[NSNotificationCenter defaultCenter] addObserverForName:@"sceneChange" object:nil queue:nil usingBlock:^(NSNotification *n) {
        [weaklyNotifiedSelf cleanUpAfterSceneChange];
    }];
    
    [_observers addObject:ob];
}
- (void) drawPagesAtIndex:(int)index {
    
    float acc = 0;
    
    int i = 1;
    // here we will draw the pages into the scene
    for (MenuPageTemplate *page in self.pages){
        
        // Asserting position here will position the contents of the page
        CGPoint point = CGPointMake(acc, 0);
        page.position = point;
        page.identifier = i;
        [self addChild:page];
        acc += _scene.size.width; // position next page to the right by acc.
        i += 1;
    }
    currentScreen_ = index;
    [self drawNavBoxes];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    lastPosition_ = location.x;
    startSwipe_ = location.x;
    state_ = kScrollLayerStateIdle;
    
    // notify menu page
    NSDictionary *update = [NSDictionary dictionaryWithObjectsAndKeys:touches, @"touches", event, @"event", [NSNumber numberWithInt:currentScreen_ ], @"currentScreen", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchesBegan" object:update];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    int moveDistance = location.x - startSwipe_;
    
    // If finger is dragged for more distance then minimum - start sliding and cancel pressed buttons.
    if ( (state_ != kScrollLayerStateSliding) && (fabsf(moveDistance) >= self.minimumTouchLengthToSlide)) {
        state_ = kScrollLayerStateSliding;
    }
    
    // drag ourselves along with user finger
    if (state_ == kScrollLayerStateSliding) {
        
        // Move individual pages to their relative positions.
        for (SKNode * node in self.pages){
            
            float newPosition = node.position.x + (location.x - lastPosition_ );
            CGPoint moveToPosition = CGPointMake(newPosition,0);
            node.position = moveToPosition;
        }
    }
    lastPosition_ = location.x;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Testing the drag length. offsetLoc is drag length, compared to minimum
    offsetLoc = 0;
    offsetLoc = (location.x - startSwipe_);
    
    // Logic to determine roughly what the user did
    if ( offsetLoc < -self.minimumTouchLengthToChangePage) {
        [self moveToPage: currentScreen_+1];
    }
    else if ( offsetLoc > self.minimumTouchLengthToChangePage) {
        [self moveToPage: currentScreen_-1];
    }
    else if ((currentScreen_-1) == 0 ) {
        
        if ( offsetLoc > self.minimumTouchLengthToChangePage) {
        }
        else{
            [self moveToPage:currentScreen_];
        }
    }
    else {
        [self moveToPage:currentScreen_];
    }
    
    state_ = kScrollLayerStateIdle;
    
    // notify menu page
    NSDictionary *update = [NSDictionary dictionaryWithObjectsAndKeys:touches, @"touches", event, @"event", [NSNumber numberWithInt:currentScreen_], @"currentScreen", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchesEnded" object:update];
    
}

- (void) initialMoveToPage:(int)page {
    
    if (page == 1) [self currentScreenWillChange];
    [self moveToPage:page];
}

- (void) moveToPage:(int)page {

    float screenWidth = _scene.size.width;
    
    // calculate initial position X values for reference
    int count = (int)[self.pages count];
    
    NSMutableArray *initialValuesArray = [NSMutableArray arrayWithObjects: nil];
    int initialValue = screenWidth;
    
    for (int i = 0; i < count; i++){
        
        [initialValuesArray addObject:[NSNumber numberWithInt:initialValue]];
        initialValue += screenWidth;
    }

    BOOL rtz = NO;
    BOOL illegalMove = NO;
    
    if (page > count || page == 0){
        illegalMove = YES;
    }
    else {
        
        int difference = (currentScreen_ - page) * -1;
        
        // if user initiated the transition use constants for drag duration else calculate based on the travel distance:
        float dragDuration = kLongDragDuration;
        if (difference > 1 || difference < 1){
            
            // further thinking on this would scale the speed according to the amount of layers
            // to animate but 1:1 sounds appropro for now...
            dragDuration = difference * kLongDragDuration;
            
            if (dragDuration < 0) dragDuration *= -1;
        }
        
        
        // Here we determine which direction the user is going and animate the selected page visible
        if (page > currentScreen_){
            // going right
            
            int i = 0;
            for (SKNode * node in self.pages){
                
                int initialItemValue = (int)[[initialValuesArray objectAtIndex:i] intValue];
                int newPosition = -(((currentScreen_ +1) * screenWidth - initialItemValue) + screenWidth * (difference - 1));
                SKAction *move = [SKAction moveTo:CGPointMake(newPosition, 0) duration:dragDuration];
                [node runAction:move];
                
                i += 1;
            }
            
            [self currentScreenWillChange];
            
            currentScreen_ = page;
            [self setDefaultPage:page];
        }
        
        else if (page < currentScreen_){
            
            // going left
            int i = 0;
            for (SKNode * node in self.pages){
                
                int initialItemValue = (int)[[initialValuesArray objectAtIndex:i] intValue];
                int newPosition = -(((currentScreen_ - 1)* screenWidth - initialItemValue) - (screenWidth * -(difference + 1)));
                SKAction *move = [SKAction moveToX:newPosition duration:dragDuration];
                [node runAction:move];
                
                i += 1;
            }
            
            currentScreen_ = page;
            [self setDefaultPage:page];
            
            [self currentScreenWillChange];
        }
        else {
            rtz = YES;
        }
    }
    
    if (rtz || illegalMove){
        
        int i = 0;
        
        for (SKNode * node in self.pages){
            
            int initialItemValue = (int)[[initialValuesArray objectAtIndex:i] intValue];
            int newPosition = (initialItemValue - currentScreen_ * screenWidth);
            
            SKAction *move = [SKAction moveToX:newPosition duration:kShortDragDuration];
            
            [node runAction:move];
            
            i += 1;
        }
        if (page > count){
            [self loadExternalPage];
        }
    }
    else {
        [self moveNavBoxes];
    }
}

- (void) currentScreenWillChange {
    
    SKAction *pauseForDuration = [SKAction waitForDuration:kLongDragDuration];
    SKAction *notifyBlock = [SKAction runBlock:^{
        [self notifyMenuPagesCurrentScreenChanged];
    }];
    NSArray *sequenceArray = [NSArray arrayWithObjects:pauseForDuration, notifyBlock, nil];
    SKAction *sequence = [SKAction sequence:sequenceArray];
    [self runAction:sequence];
}

- (void) notifyMenuPagesCurrentScreenChanged {
    
    NSNumber *update = [NSNumber numberWithInt:currentScreen_];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"screenChanged" object:update];
    
}

- (void) loadExternalPage {

    NSLog(@"Load a different scene at end of scroller");
}

-(void) setDefaultPage:(int)page {
    
    [[NSUserDefaults standardUserDefaults] setInteger:page forKey:@"scrollPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) cleanUpAfterSceneChange{
    
    // kill off the observers in the menu pages
    for (MenuPageTemplate *page in self.pages){
        [page removeObservers];
    }
    
    // remove the references contained in the _pages array
    _pages = nil;
    
    // kills off the menu pages
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKNode* child = obj;
        [child removeAllActions];
    }];
    
    // remove child nodes after any transition effects may have happened
    timer = [NSTimer scheduledTimerWithTimeInterval:2.1
                                             target:self
                                           selector:@selector(removeChildNodes)
                                           userInfo:nil
                                            repeats:NO];
    
    // kill off the reference to the scene;
    _scene = nil;
}

- (void) removeChildNodes {
    
    [timer invalidate];
    timer = nil;
    [self removeAllChildren];
}



- (void) drawNavBoxes {
    
    // id how many small boxes we need
    // need to subtract for the large box
    int smallBoxes = (int)[self.pages count] - 1;
    
    // going to put all boxes on a layer
    NSMutableArray *navBoxes = [NSMutableArray arrayWithObjects: nil];
    
    // create a large box, place offstage, downstage center
    SKTexture *largeBoxTex = [SKTexture textureWithImageNamed:@"largeNavBox.png"];
    SKSpriteNode *largeNavBox = [SKSpriteNode spriteNodeWithTexture:largeBoxTex];
    largeNavBox.position = CGPointMake((_scene.size.width  / 10) * 5 , -_scene.size.height);
    largeNavBox.name = @"25";
    [navBoxes addObject:largeNavBox];
    [self addChild:largeNavBox];
    
    for (int i = 0; i < smallBoxes; i++){
        
        // create a small box, place offstage, downstage center
        SKTexture *smallBoxTex = [SKTexture textureWithImageNamed:@"smallNavBox.png"];
        SKSpriteNode *smallNavBox = [SKSpriteNode spriteNodeWithTexture:smallBoxTex];
        smallNavBox.position = CGPointMake((_scene.size.width  / 10) * 5 , -_scene.size.height);
        smallNavBox.name = [NSString stringWithFormat:@"%i", (26 + i)];
        [navBoxes addObject:smallNavBox];
        [self addChild:smallNavBox];
    }
    
    // and move into place...
    [self moveNavBoxes];
}

- (void) moveNavBoxes {
    
    // Need to know how many chapters exist; draw one less than that
    // Need to know which chapter is selected
    
    int tenthOfWidth = _scene.size.width  / 10; // 1/10th of the width
    int boxSpacing = tenthOfWidth * .5; // 1 = 10% of screen width
    int smallBoxes = (int)[self.pages count] - 1; // How many boxes exist
    
    // negative offset:
    // 1. amount of total boxes, big and small
    // 2. multiply by width of the box for total box footprint
    // 3. divide by negative 2 to get the negative offset from center
    // 4. add back half the width of one space for object offset adjustment
    int negativeOffset = (((smallBoxes + 1) * boxSpacing)/-2) + boxSpacing/2;
    
    // set the accumulator to the width of screen plus the negative offset
    int accSpacing = _scene.size.width/2 + negativeOffset;
    
    // going to create an array that contains the drawrering locations of X
    NSMutableArray *locations = [NSMutableArray arrayWithObjects:nil];
    
    // iterate and add locations to NSMA
    for (int i = 0; i < smallBoxes +1; i++){
        
        NSNumber *xCoord = [NSNumber numberWithInt:accSpacing];
        [locations addObject:xCoord];
        accSpacing += boxSpacing;
    }
    
    int x = 0;
    // the amount of locations is the total number of boxes (-1)
    int smBoxes = (int)[locations count];
    
    // so now we are looping through locations and applying x to the graphic, and setting an animation
    for (NSNumber *xCoord in locations){
        
        // BUT it is necessary to see which page is actually selected
        BOOL selected = NO;
        
        // which x + 2 does: x (0) page 1(unused) (page2 - bangkok)
        if (x + 1 == currentScreen_){
            selected = YES;
        }
        if (!selected){
            
            // small boxes' tags start from 26. add box to location and subtract one
            SKSpriteNode *small = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%i", 24 + smBoxes]];
            SKAction *moveAction = [SKAction moveTo:CGPointMake([xCoord intValue],_scene.size.height / 10 * .6) duration:.25];
            [small runAction:moveAction];
            smBoxes -=1;
        }
        else {
            
            // large box, since there is only one; it's tag is 25
            SKSpriteNode *large = (SKSpriteNode*)[self childNodeWithName:@"25"];
            SKAction *moveAction = [SKAction moveTo:CGPointMake([xCoord intValue],_scene.size.height / 10 * .6) duration:.25];
            [large runAction:moveAction];
        }
        x += 1;
    }
}

- (void)dealloc
{
    for (id ob in _observers){
        [[NSNotificationCenter defaultCenter] removeObserver:ob];
    }
}

@end

