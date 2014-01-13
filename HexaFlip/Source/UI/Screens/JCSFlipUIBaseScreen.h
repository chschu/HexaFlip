//
//  JCSFlipUIBaseScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.02.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

// partial implementation of JCSFlipUIScreenWithPoint
@interface JCSFlipUIBaseScreen : CCNode

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

@end
