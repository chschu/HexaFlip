//
//  JCSFlipUIScreenWithPoint
//  HexaFlip
//
//  Created by Christian Schuster on 16.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScreen.h"

// protocol for screens that also have a position, i.e. are visible somewhere
@protocol JCSFlipUIScreenWithPoint <JCSFlipUIScreen>

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

@end
