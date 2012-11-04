//
//  JCSFlipUIScreen.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// protocol used by the scene to communicate with the individual screens
@protocol JCSFlipUIScreen <NSObject>

// disable any user actions on the screen
@property (nonatomic) BOOL screenEnabled;

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

@end
