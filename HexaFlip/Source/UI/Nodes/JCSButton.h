//
//  JCSButton.h
//  HexaFlip
//
//  Created by Christian Schuster on 29.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
    JCSButtonSizeSmall = 53,
    JCSButtonSizeMedium = 73,
    JCSButtonSizeLarge = 100,
} JCSButtonSize;

@interface JCSButton : CCMenuItemSprite

- (id)initWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block;

+ (id)buttonWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block;

@end
