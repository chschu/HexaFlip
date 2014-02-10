//
//  JCSFlipMove.h
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexDirection.h"
#import "JCSMove.h"

@protocol JCSFlipMoveInputDelegate;

@interface JCSFlipMove : NSObject <NSCopying, JCSMove>

// property indicating that this is a "skip" move
// if this is YES, the other move properties cannot be read
@property (nonatomic) BOOL skip;

// the starting row of the move
@property (nonatomic) NSInteger startRow;

// the starting column of the move
@property (nonatomic) NSInteger startColumn;

// the hexagonal direction of the move
@property (nonatomic) JCSHexDirection direction; 

// convenience methods
+ (instancetype)moveWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;
+ (instancetype)moveSkip;

// initialize new instances
- (instancetype)initWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;
- (instancetype)initSkip;

- (void)performInputWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate;

@end
