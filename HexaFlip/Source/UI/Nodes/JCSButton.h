//
//  JCSButton.h
//  HexaFlip
//
//  Created by Christian Schuster on 29.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

typedef NS_ENUM(NSInteger, JCSButtonSize) {
    JCSButtonSizeSmall = 53,
    JCSButtonSizeMedium = 73,
    JCSButtonSizeLarge = 100,
};

@interface JCSButton : CCMenuItemSprite

- (id)initWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block;

+ (instancetype)buttonWithSize:(JCSButtonSize)size name:(NSString *)name block:(void(^)(id sender))block;

@end
