//
//  JCSFlipUIBaseScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.02.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScreenWithPoint.h"

#import "cocos2d.h"

// partial implementation of JCSFlipUIScreenWithPoint
@interface JCSFlipUIBaseScreen : CCNode {
    @protected
    // value of the "screenEnabled" property, so subclasses can set it
    BOOL _screenEnabled;
}

// "enabled" indicator of the screen
@property (readonly, nonatomic) BOOL screenEnabled;

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

@end
