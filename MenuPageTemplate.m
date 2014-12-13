//
//  MenuPageTemplate.m
//  KRGameScroll
//
//  Created by Keny Ruyter on 12/12/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//

// There are two ways you can go about architecting your menu scene.
// One option would be to try and encapsulate all of your code here (Architecture 1)
// in MenuPageTemplate.h. Or, what I tend to do is (Architecture 2) I will use a separate
// template page to manage the various features, like unlocked in app purchases etc.

#import "MenuPageTemplate.h"
#import "GameScene.h"
#import "AnotherScene.h"

@implementation MenuPageTemplate

// we keep a reference to the scene and get our
// page number in order to be referred to

- (id)initFromScene:(SKScene*)scene page:(int)page{
    self = [super init];
    if (self) {
        
        // KRGameScroll will get the touches and pass them here via NSNotification.
        [self registerObservers];
        
        _scene = scene;
        
        // the class assumes you are using the entire screen
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        // store node references into an array for quick reference
        nodes = [[NSMutableSet alloc]initWithObjects: nil];
        
        // begin page specific content here
        
        // may want to determine font size based on phone / tablet
        int fontSize = 24;
        
        // Draw heading based on what page we are assigned (Architecture 1)
        SKTexture *btnTex = [SKTexture textureWithImageNamed:@"goTo.png"];
        [self drawButtonArrayWithTexture: btnTex];

        NSString *pageTitle;
    
        switch (page) {
                
            case 1: pageTitle = @"Rad Game 1"; break;
            case 2: pageTitle = @"Rad Game 2"; break;
            case 3: pageTitle = @"Rad Game 3"; break;
            case 4: pageTitle = @"Rad Game 4"; break;
                
            default:
                break;
        }
        
        SKLabelNode *pageLabel = [SKLabelNode labelNodeWithFontNamed:@"Thonburi-Bold"];
        pageLabel.fontSize = fontSize;
        pageLabel.text = pageTitle;
        pageLabel.fontColor = [UIColor colorWithRed:0.232132 green:0.224964 blue:0.235748 alpha:1.0];
        pageLabel.position = CGPointMake(screenRect.size.width/10 * 5,screenRect.size.height/10 * 2);
        [self addChild:pageLabel];
        
        // end page specific content
        
    }
    return self;
}


// use touchBegan for selection Animations and sound responsiveness
- (void) notificationTouchBegan:(NSDictionary*) info {
    
    NSNumber *currentScreen = [info objectForKey:@"currentScreen"];
    if ([currentScreen intValue] == _identifier){
        
        NSSet *touches = [info objectForKey:@"touches"];
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        
        SKNode *nodeAtPoint;
        for (SKNode *selectedNode in [self nodesAtPoint:location]){
            
            // check to see if button is named
            // might need to tweak this for multiple named nodes at the same point
            if (selectedNode.name){
                nodeAtPoint = selectedNode;
            }
        }
        for (id buttonNode in nodes){
            if ([buttonNode isEqual:nodeAtPoint]){
                // [[SoundManager sharedManager] playSample:@"BrushClk.caf" volume:1];
                [self scaleAction:nodeAtPoint];
            }
        }
    }
}

- (void) notificationTouchEnded:(NSDictionary*) info {
    
    NSNumber *currentScreen = [info objectForKey:@"currentScreen"];
    
    if ([currentScreen intValue] == _identifier){
        
        NSSet *touches = [info objectForKey:@"touches"];
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        
        SKNode *nodeAtPoint;
        for (SKNode *selectedNode in [self nodesAtPoint:location]){
            
            // check to see if button is named
            // might need to tweak this for multiple named nodes at the same point
            if (selectedNode.name){
                nodeAtPoint = selectedNode;
            }
        }
        
        for (id buttonNode in nodes){
            
            // Load selected scene if correct button
            // in this case as long as any button on a given page is selected,
            // the same scene per page will load
            if ([buttonNode isEqual:nodeAtPoint]){
                
                NSLog(@"Start Scene %i at Level: %@", _identifier, nodeAtPoint.name);
                
                // Uncomment the following code when you are ready to begin testing the next scene
                
                // Load your game scene here
                AnotherScene * newScene = [AnotherScene sceneWithSize:[[UIScreen mainScreen] bounds].size];
                 
                // i like to set a property on the new scene to establish level
                newScene.startLevel = nodeAtPoint.name;
                
                // Transition to the new scene: Must set pause outgoing to NO to complete selection animations
                SKTransition *tranny = [SKTransition crossFadeWithDuration:1];
                tranny.pausesOutgoingScene = NO;
                 
                SKView * skView = _scene.view;
                [skView presentScene:newScene transition:tranny];

                // Finally to call begin on the new scene
                [newScene begin];
                
                // This is for cleanup code that kills KRGameScroll
                NSArray *update = [NSArray arrayWithObjects:@"sceneWillChange", newScene ,nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sceneChange" object:update];
                
            }
        }
    }
}

// This notification can be useful if you want to start
// an animation or run audio when a page is scrolled upon.
- (void) notificationScreenChanged:(NSNumber*)screen {
    if ([screen intValue] == _identifier){
        // NSLog(@"Moved to screen: %@", screen);
    }
}

// Just to keep things simple we assume each page has 9 buttons.
// This is a good reason to switch to architecture 2
- (void) drawButtonArrayWithTexture:(SKTexture*)texture {
    
    // init and draw nodes, add reference to array
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    int border = screenRect.size.width / 10 * 3; // 30 percent outside border: edge to center of outside tile
    int totalBorder = border * 2;
    int useableArea = screenRect.size.width - totalBorder;
    int columns = 3;
    int spans = columns - 1;
    int span = useableArea / spans;
    int startPoint = border;
    
    // Row 1
    for (int i = 0; i < columns; i++){
        
        SKSpriteNode *menuBtn = [SKSpriteNode spriteNodeWithTexture:texture];
        menuBtn.position = CGPointMake(startPoint, screenRect.size.height/10 * 7.5);
        [self addChild:menuBtn];
        menuBtn.name = [NSString stringWithFormat:@"%i", i + 1];
        [nodes addObject:menuBtn];
        
        startPoint += span;
    }
    
    startPoint = border;
    
    // Row 2
    for (int i = 0; i < columns; i++){
        
        SKSpriteNode *menuBtn = [SKSpriteNode spriteNodeWithTexture:texture];
        menuBtn.position = CGPointMake(startPoint, screenRect.size.height/10 * 6);
        [self addChild:menuBtn];
        menuBtn.name = [NSString stringWithFormat:@"%i", i + 1 + 3];
        [nodes addObject:menuBtn];
        
        startPoint += span;
    }
    
    startPoint = border;
    
    // Row 3
    for (int i = 0; i < columns; i++){
        
        SKSpriteNode *menuBtn = [SKSpriteNode spriteNodeWithTexture:texture];
        menuBtn.position = CGPointMake(startPoint, screenRect.size.height/10 * 4.5);
        [self addChild:menuBtn];
        menuBtn.name = [NSString stringWithFormat:@"%i", i + 1 + 6];
        [nodes addObject:menuBtn];
        
        startPoint += span;
    }
}

// This is to give a little popUp action when needed
-(void) scaleAction:(SKNode*)node{
    
    float scaleD = .95;
    float rtnScale = 1;
    float scaleU =  1.05;
    
    NSMutableArray *scaleAct = [NSMutableArray arrayWithObjects: nil];
    
    SKAction *scaleDown = [SKAction scaleTo:scaleD duration:kNodeSelectDuration];
    SKAction *scaleUp = [SKAction scaleTo:scaleU duration:kNodeSelectDuration];
    SKAction *scaleRtn = [SKAction scaleTo:rtnScale duration:kNodeSelectDuration];
    
    [scaleAct addObject:scaleDown];
    [scaleAct addObject:scaleUp];
    [scaleAct addObject:scaleRtn];
    
    [node runAction:[SKAction sequence:scaleAct]];
    
}

- (void) registerObservers {
    
    // Observe Touch event messages from Menu class, who is receiving touch events
    self ->_observers = [NSMutableSet set];
    __weak __typeof(self) weaklyNotifiedSelf = self;
    
    id ob = [[NSNotificationCenter defaultCenter] addObserverForName:@"touchesBegan" object:nil queue:nil usingBlock:^(NSNotification *n) {
        NSDictionary *update = [n object];
        [weaklyNotifiedSelf notificationTouchBegan:update];
    }];
    
    [_observers addObject:ob];
    
    id ob1 = [[NSNotificationCenter defaultCenter] addObserverForName:@"touchesEnded" object:nil queue:nil usingBlock:^(NSNotification *n) {
        NSDictionary *update = [n object];
        [weaklyNotifiedSelf notificationTouchEnded:update];
    }];
    
    [_observers addObject:ob1];
    
    
    id ob2 = [[NSNotificationCenter defaultCenter] addObserverForName:@"screenChanged" object:nil queue:nil usingBlock:^(NSNotification *n) {
        NSNumber *screen = [n object];
        [weaklyNotifiedSelf notificationScreenChanged:screen];
    }];
    
    [_observers addObject:ob2];
}

- (void) removeObservers {
    nodes = nil;
    for (id ob in _observers){
        [[NSNotificationCenter defaultCenter] removeObserver:ob];
    }
}

- (void)dealloc
{
    nodes = nil;
    // NSLog(@"MenuPage: Dealloc");
}

@end
