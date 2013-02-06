//
//  JCSFlipUIScreenWithPoint
//  HexaFlip
//
//  Created by Christian Schuster on 16.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

// protocol for screens that also have a position, i.e. are visible somewhere
@protocol JCSFlipUIScreenWithPoint <NSObject>

// set to NO to disable any user actions on the screen
@property (nonatomic) BOOL screenEnabled;

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

@end
