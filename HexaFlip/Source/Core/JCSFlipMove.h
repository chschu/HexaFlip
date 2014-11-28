//
//  JCSFlipMove.h
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexDirection.h"

@protocol JCSFlipMoveInputDelegate;

@interface JCSFlipMove : NSObject <NSCopying>

// property indicating that this is a "skip" move
// if this is YES, the other move properties cannot be read
@property (nonatomic) BOOL skip;

// the starting row of the move
@property (nonatomic) NSInteger startRow;

// the starting column of the move
@property (nonatomic) NSInteger startColumn;

// the hexagonal direction of the move
@property (nonatomic) JCSHexDirection direction; 

// initialize new instance (normal move)
- (instancetype)initWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;

// initialize new instance (skip move)
- (instancetype)init;

- (void)performInputWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate;

@end
