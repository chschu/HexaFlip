//
//  JCSFlipMutableMove.h
//  HexaFlip
//
//  Created by Christian Schuster on 28.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSHexDirection.h"

// mutable move (see JCSFlipMove for immutable variant)
@interface JCSFlipMutableMove : JCSFlipMove

// property indicating that this is a "skip" move
// if this is YES, the other move properties cannot be read, but may be written
@property (nonatomic) BOOL skip;

// the starting row of the move
@property (nonatomic) NSInteger startRow;

// the starting column of the move
@property (nonatomic) NSInteger startColumn;

// the hexagonal direction of the move
@property (nonatomic) JCSHexDirection direction;

@end
