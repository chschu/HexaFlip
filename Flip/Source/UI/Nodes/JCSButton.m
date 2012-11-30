//
//  JCSButton.m
//  Flip
//
//  Created by Christian Schuster on 29.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSButton.h"

@implementation JCSButton

- (id)initWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block {
    NSString *sizeString;
    if (size == JCSButtonSizeSmall) {
        sizeString =@"small";
    } else if (size == JCSButtonSizeMedium) {
        sizeString = @"medium";
    } else if (size == JCSButtonSizeLarge) {
        sizeString = @"large";
    } else {
        NSAssert(false, @"invalid argument");
    }
    
    NSString *backgroundSpriteFrameName = [NSString stringWithFormat:@"button-background-%@.png", sizeString];
    NSString *normalSpriteFrameName = [NSString stringWithFormat:@"button-%@-%@-normal.png", sizeString, name];
    NSString *selectedSpriteFrameName = [NSString stringWithFormat:@"button-%@-%@-pushed.png", sizeString, name];
    NSString *disabledSpriteFrameName = [NSString stringWithFormat:@"button-%@-%@-disabled.png", sizeString, name];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCSpriteFrame *normalSpriteFrame = [cache spriteFrameByName:normalSpriteFrameName];
    CCSpriteFrame *selectedSpriteFrame = [cache spriteFrameByName:selectedSpriteFrameName];
    CCSpriteFrame *disabledSpriteFrame = [cache spriteFrameByName:disabledSpriteFrameName];

    CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:backgroundSpriteFrameName];
    
    CCSprite *normalSprite;
    CCSprite *selectedSprite;
    CCSprite *disabledSprite;
    
    if (normalSpriteFrame != nil) {
        normalSprite = [CCSprite spriteWithSpriteFrame:normalSpriteFrame];
    } else {
        normalSprite = nil;
    }
    if (selectedSpriteFrame != nil) {
        selectedSprite = [CCSprite spriteWithSpriteFrame:selectedSpriteFrame];
    } else {
        selectedSprite = nil;
    }
    if (disabledSpriteFrame != nil) {
        disabledSprite = [CCSprite spriteWithSpriteFrame:disabledSpriteFrame];
    } else {
        disabledSprite = nil;
    }

    if (self = [super initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block]) {
        // add background sprite centered, but keep content size
		[self addChild:backgroundSprite z:-1];
        backgroundSprite.anchorPoint = ccp(0.5,0.5);
        backgroundSprite.position = ccpMult(ccpFromSize(normalSprite.contentSize), 0.5);
    }
    
    return self;
}

+ (id)buttonWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block {
    return [[self alloc] initWithSize:size name:name block:block];
}

@end
