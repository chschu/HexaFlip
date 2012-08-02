//
//  JCSFlipUIGameOverLayer.m
//  Flip
//
//  Created by Christian Schuster on 02.08.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIGameOverLayer.h"
#import "JCSFlipUIMainMenuScene.h"

@implementation JCSFlipUIGameOverLayer

+ (CCLayer *)layerWithText:(NSString *)text {
    return [[self alloc] initWithText:text];
}

- (id)initWithText:(NSString *)text {
    if (self = [super initWithColor:ccc4(0, 0, 0, 127)]) {
        
        CCDirector *director = [CCDirector sharedDirector];
        
        NSInteger windowWidth = director.winSize.width;
        NSInteger windowHeight = director.winSize.height;

        CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:40];
        label.position = ccp(windowWidth/2, windowHeight/2);
        
        [self addChild:label];
    }
    return self;
}

- (void)onEnter {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCScene *scene = [JCSFlipUIMainMenuScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5 scene:scene]];
    
    return YES;
}

@end
