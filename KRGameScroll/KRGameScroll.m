//
//  KRGameScroll.m
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Keny Ruyter
//  keny@eastcoastbands.com

#import "KRGameScroll.h"
#import "MenuPageTemplate.h"

enum
{
    kScrollLayerStateIdle,
    kScrollLayerStateSliding,
};

// custom configuration variables 1 of 2
#define kShortDragDuration .10
#define kLongDragDuration .25

@implementation KRGameScroll

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
    
    // custom configuration variables 2 of 2
    showNavBoxes = YES;
    minimumSlideLength = 5;
    minimumDragThreshold = 20;
    currentScreen = 1;
    
    self ->observers = [NSMutableSet set];
    __weak __typeof(self) weaklyNotifiedSelf = self;
    
    id ob = [[NSNotificationCenter defaultCenter] addObserverForName:@"sceneChange" object:nil queue:nil usingBlock:^(NSNotification *n) {
        [weaklyNotifiedSelf cleanUpAfterSceneChange];
    }];
    
    [observers addObject:ob];
}
- (void) drawPagesAtIndex:(int)index {
    
    float acc = 0;
    
    int i = 1;
    // here we will draw the pages into the scene
    for (MenuPageTemplate *page in self.pages){
        
        // Asserting position here will position the contents of the page
        CGPoint point;
        if (isVertical) point = CGPointMake(0, acc);
        else point = CGPointMake(acc, 0);
        page.position = point;
        page.identifier = i;
        [self addChild:page];
        
        if (isVertical) acc -= _scene.size.height;
        else acc += _scene.size.width; // position next page to the right by acc.
        
        i += 1;
    }
    currentScreen = index;
    
    if (showNavBoxes){
        [self drawNavBoxes];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (isVertical) {
        lastPosition = location.y;
        startSwipe = location.y;
    }
    else {
        lastPosition = location.x;
        startSwipe = location.x;
    }
    
    state = kScrollLayerStateIdle;
    
    // notify menu page
    NSDictionary *update = [NSDictionary dictionaryWithObjectsAndKeys:touches, @"touches", event, @"event", [NSNumber numberWithInt:currentScreen ], @"currentScreen", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchesBegan" object:update];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    int moveDistance;
    if (isVertical) moveDistance = location.y - startSwipe;
    else moveDistance = location.x - startSwipe;
    
    // If finger is dragged for more distance then minimum - start sliding and cancel pressed buttons.
    if ( (state != kScrollLayerStateSliding) && (fabsf(moveDistance) >= minimumSlideLength)) {
        state = kScrollLayerStateSliding;
    }
    
    // drag ourselves along with user finger
    if (state == kScrollLayerStateSliding) {
        
        // Move individual pages to their relative positions.
        for (SKNode * node in self.pages){
            
            CGPoint moveToPosition;
            float newPosition;
            
            if (isVertical){
                newPosition = node.position.y + (location.y - lastPosition );
                moveToPosition = CGPointMake(0,newPosition);
            }
            else {
                newPosition = node.position.x + (location.x - lastPosition );
                moveToPosition = CGPointMake(newPosition,0);
            }
            node.position = moveToPosition;
        }
    }
    
    if (isVertical) lastPosition = location.y;
    else lastPosition = location.x;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Testing the drag length. offsetLoc is drag length, compared to minimum
    int offsetLoc = 0;
    
    if (isVertical) offsetLoc = (location.y - startSwipe);
    else offsetLoc = (location.x - startSwipe);
    
    // Logic to determine roughly what the user did
    if ( offsetLoc < -minimumDragThreshold) {
        if (isVertical) [self moveToPage: currentScreen-1];
        else [self moveToPage: currentScreen+1];
    }
    else if ( offsetLoc > minimumDragThreshold) {
        if (isVertical) [self moveToPage: currentScreen+1];
        else [self moveToPage: currentScreen-1];
    }
    else if ((currentScreen-1) == 0 ) {
        
        if ( offsetLoc > minimumDragThreshold) {
        }
        else{
            [self moveToPage:currentScreen];
        }
    }
    else {
        [self moveToPage:currentScreen];
    }
    
    state = kScrollLayerStateIdle;
    
    // notify menu page
    NSDictionary *update = [NSDictionary dictionaryWithObjectsAndKeys:touches, @"touches", event, @"event", [NSNumber numberWithInt:currentScreen], @"currentScreen", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchesEnded" object:update];
    
}

- (void) initialMoveToPage:(int)page {
    
    if (page == 1) [self currentScreenWillChange];
    [self moveToPage:page];
}

- (void) moveToPage:(int)page {
    
    float screenWidth;
    if (isVertical) screenWidth = _scene.size.height;
    else screenWidth = _scene.size.width;
    
    // calculate initial position X values for reference
    int count = (int)[self.pages count];
    
    NSMutableArray *initialValuesArray = [NSMutableArray arrayWithObjects: nil];
    int initialValue = screenWidth;
    
    for (int i = 0; i < count; i++){
        
        [initialValuesArray addObject:[NSNumber numberWithInt:initialValue]];
        if (isVertical) initialValue += screenWidth;
        else initialValue += screenWidth;
    }

    BOOL rtz = NO;
    BOOL illegalMove = NO;
    
    if (page > count || page == 0){
        illegalMove = YES;
    }
    else {
        
        int difference = (currentScreen - page) * -1;
        
        // if user initiated the transition use constants for drag duration else calculate based on the travel distance:
        float dragDuration = kLongDragDuration;
        if (difference > 1 || difference < 1){
            
            // further thinking on this would scale the speed according to the amount of layers
            // to animate but 1:1 sounds appropro for now...
            dragDuration = difference * kLongDragDuration;
            
            if (dragDuration < 0) dragDuration *= -1;
        }
        
        // Here we determine which direction the user is going and animate the selected page visible
        if (page > currentScreen){
            // going right
            
            int i = 0;
            for (SKNode * node in self.pages){
                
                int initialItemValue = (int)[[initialValuesArray objectAtIndex:i] intValue];
                
                SKAction *move;
                int newPosition;
                
                if (isVertical){

                    newPosition = +(((currentScreen +1) * screenWidth - initialItemValue) + screenWidth * (difference - 1));
                    move = [SKAction moveTo:CGPointMake(0, newPosition) duration:dragDuration];
                }
                
                else {
                    newPosition = -(((currentScreen +1) * screenWidth - initialItemValue) + screenWidth * (difference - 1));
                    move = [SKAction moveTo:CGPointMake(newPosition, 0) duration:dragDuration];
                }
                
                [node runAction:move];
                
                i += 1;
            }
            
            [self currentScreenWillChange];
            
            currentScreen = page;
            [self setDefaultPage:page];
        }
        
        else if (page < currentScreen){
            
            // going left
            int i = 0;
            for (SKNode * node in self.pages){
                
                int initialItemValue = (int)[[initialValuesArray objectAtIndex:i] intValue];
                
                SKAction *move;
                int newPosition;
                
                if (isVertical){
                    newPosition = +(((currentScreen - 1) * screenWidth - initialItemValue) + (screenWidth * -(difference + 1)));
                    move = [SKAction moveToY:newPosition duration:dragDuration];
                }
                else {
                    newPosition = -(((currentScreen - 1) * screenWidth - initialItemValue) - (screenWidth * -(difference + 1)));
                    move = [SKAction moveToX:newPosition duration:dragDuration];
                }
                
                [node runAction:move];
                
                i += 1;
            }
            
            currentScreen = page;
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
            
            SKAction *move;
            int newPosition;
            
            if (isVertical){
                
                newPosition = -(initialItemValue - currentScreen * screenWidth);
                move = [SKAction moveToY:newPosition duration:kShortDragDuration];
                
            }
            else {
                newPosition = (initialItemValue - currentScreen * screenWidth);
                move = [SKAction moveToX:newPosition duration:kShortDragDuration];
            }
            
            [node runAction:move];
            
            i += 1;
        }
        if (page > count){
            [self loadExternalPage];
        }
    }
    else {
        if (showNavBoxes){
            [self moveNavBoxes];
        }
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
    
    NSNumber *update = [NSNumber numberWithInt:currentScreen];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"screenChanged" object:update];
    
}

- (void) loadExternalPage {

    // NSLog(@"Load a different scene at end of scroller");
    NSNumber *update = [NSNumber numberWithInt:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadExternalPage" object:update];
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
    if (isVertical) largeNavBox.position =
        CGPointMake(_scene.size.width + largeNavBox.size.width, _scene.size.height / 2 );
    else largeNavBox.position = CGPointMake((_scene.size.width  / 10) * 5 , -_scene.size.height);
    largeNavBox.name = @"25";
    [navBoxes addObject:largeNavBox];
    [self addChild:largeNavBox];
    
    for (int i = 0; i < smallBoxes; i++){
        
        // create a small box, place offstage, downstage center
        SKTexture *smallBoxTex = [SKTexture textureWithImageNamed:@"smallNavBox.png"];
        SKSpriteNode *smallNavBox = [SKSpriteNode spriteNodeWithTexture:smallBoxTex];
        if (isVertical) smallNavBox.position = CGPointMake(_scene.size.width + smallNavBox.size.width, _scene.size.height / 2);
        else smallNavBox.position = CGPointMake((_scene.size.width  / 10) * 5 , -_scene.size.height);
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
    int accSpacing;
    if (isVertical) accSpacing = _scene.size.height/2 - negativeOffset;
    else accSpacing = _scene.size.width/2 + negativeOffset;
    
    // create an array that contains the drawrering locations of X
    NSMutableArray *locations = [NSMutableArray arrayWithObjects:nil];
    
    // iterate and add locations to NSMA
    for (int i = 0; i < smallBoxes +1; i++){
        
        NSNumber *xCoord = [NSNumber numberWithInt:accSpacing];
        [locations addObject:xCoord];
        
        if (isVertical)accSpacing -= boxSpacing;
        else accSpacing += boxSpacing;
    }
    
    int x = 0;
    // the amount of locations is the total number of boxes (-1)
    int smBoxes = (int)[locations count];
    
    // so now we are looping through locations and applying x to the graphic, and setting an animation
    for (NSNumber *xCoord in locations){
        
        // BUT it is necessary to see which page is actually selected
        BOOL selected = NO;
        
        // which x + 2 does: x (0) page 1(unused) (page2 - bangkok)
        if (x + 1 == currentScreen){
            selected = YES;
        }
        if (!selected){
            
            // small boxes' tags start from 26. add box to location and subtract one
            SKSpriteNode *small = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"%i", 24 + smBoxes]];
            SKAction *moveAction;
            if (isVertical) moveAction = [SKAction moveTo:CGPointMake(_scene.size.width / 10 * 9.4, [xCoord intValue]) duration:.25];
            else moveAction = [SKAction moveTo:CGPointMake([xCoord intValue],_scene.size.height / 10 * .6) duration:.25];
            [small runAction:moveAction];
            smBoxes -=1;
        }
        else {
            
            // large box, since there is only one; it's tag is 25
            SKSpriteNode *large = (SKSpriteNode*)[self childNodeWithName:@"25"];
            SKAction *moveAction;
            if (isVertical) moveAction = [SKAction moveTo:CGPointMake(_scene.size.width / 10 * 9.4, [xCoord intValue]) duration:.25];
            else moveAction = [SKAction moveTo:CGPointMake([xCoord intValue],_scene.size.height / 10 * .6) duration:.25];
            [large runAction:moveAction];
        }
        x += 1;
    }
}

- (void)dealloc
{
    for (id ob in observers){
        [[NSNotificationCenter defaultCenter] removeObserver:ob];
    }
}

@end

