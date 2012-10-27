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
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        backgroundSprite.anchorPoint = ccp(0,0);
        backgroundSprite.position = ccp(0,0);
        [self addChild:backgroundSprite];
    }
    return self;
}

@end
