//
//  JCSButton.h
//  HexaFlip
//
//  Created by Christian Schuster on 29.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
    JCSButtonSizeSmall = 44,
    JCSButtonSizeMedium = 61,
    JCSButtonSizeLarge = 84,
} JCSButtonSize;

@interface JCSButton : CCMenuItemSprite

- (id)initWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block;

+ (id)buttonWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block;

@end
