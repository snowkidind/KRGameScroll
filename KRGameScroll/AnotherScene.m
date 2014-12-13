//
//  AnotherScene.m
//  ScrollMe
//
//  Created by Keny Ruyter on 8/19/14.
//  Copyright (c) 2014 Art Of Communication, Inc. All rights reserved.
//

#import "AnotherScene.h"
#import "GameScene.h"

@implementation AnotherScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {

        self.userInteractionEnabled = YES;
        
        // store nodes into array for quick reference
        nodes = [[NSMutableSet alloc]initWithObjects: nil];
        
        // A Button
        SKTexture *btnTex = [SKTexture textureWithImageNamed:@"goTo.png"];
        SKSpriteNode *menuBtn = [SKSpriteNode spriteNodeWithTexture:btnTex];
        menuBtn.position = CGPointMake(size.width/10*8, size.height/10*2);
        [self addChild:menuBtn];
        [nodes addObject:menuBtn];

    }
    return self;
}

- (void) begin{


}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    // iterate through select nodes to determine what scene to load etc
    for (id buttonNode in nodes){
        
        if ([buttonNode isEqual:node]){
            
            // handle on the original scene
            SKView * skView = self.view;
            GameScene * newScene = [GameScene sceneWithSize:[[UIScreen mainScreen] bounds].size];

            [skView presentScene:newScene];
            
        }
    }
}

- (void)dealloc
{
    // NSLog(@"AnotherScene: Dealloc");
}

@end
