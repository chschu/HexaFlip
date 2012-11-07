//
//  JCSFlipUIMainMenuScreen.m
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIMainMenuScreen.h"

@implementation JCSFlipUIMainMenuScreen

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

- (id)init {
    if (self = [super init]) {
        CCMenuItem *playItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-play-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-play-pushed.png"] block:^(id sender) {
            if (_screenEnabled) {
                [_delegate play];
            }
        }];
        CCMenu *menu = [CCMenu menuWithItems:playItem, nil];
        [self addChild:menu];
    }
    return self;
}

@end
