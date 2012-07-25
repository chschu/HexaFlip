//
//  JCSFlipMove.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexDirection.h"

@interface JCSFlipMove : NSObject

// property indicating that this is a "skip" move
// if this is YES, the other move properties cannot be accessed
@property (readonly) BOOL skip;

// the starting row of the move
@property (readonly) NSInteger startRow;

// the starting column of the move
@property (readonly) NSInteger startColumn;

// the hexagonal direction of the move
@property (readonly) JCSHexDirection direction; 

// recycle cached instances
+ (id)moveWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;
+ (id)moveSkip;

// initialize new instances
- (id)initWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;
- (id)initSkip;

@end
