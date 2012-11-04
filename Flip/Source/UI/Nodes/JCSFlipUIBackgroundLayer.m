//
//  JCSFlipUIBackgroundLayer.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBackgroundLayer.h"

@implementation JCSFlipUIBackgroundLayer

- (id)init {
    if (self = [super init]) {
        CCDirector *director = [CCDirector sharedDirector];
        NSInteger windowWidth = director.winSize.width;
        
        // place background on the right border
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        backgroundSprite.anchorPoint = ccp(1,0);
        backgroundSprite.position = ccp(windowWidth,0);
        [self addChild:backgroundSprite];
    }
    return self;
}

@end
