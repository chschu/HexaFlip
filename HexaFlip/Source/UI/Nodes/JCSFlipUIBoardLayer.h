//
//  JCSFlipUIBoardLayer.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUICellNodeTouchDelegate.h"

#import "cocos2d.h"

@protocol JCSFlipPlayer;
@protocol JCSFlipMoveInputDelegate;
@class JCSFlipGameState;

// the layer displaying the current board
@interface JCSFlipUIBoardLayer : CCNode <JCSFlipUICellNodeTouchDelegate>

// the delegate for forward input information to
@property (weak, nonatomic) id<JCSFlipMoveInputDelegate> inputDelegate;

// is local move input enabled (NO by default)
@property (nonatomic) BOOL moveInputEnabled;

// initializes the view with the given game state
+ (instancetype)nodeWithState:(JCSFlipGameState *)state;

// asynchronously start an animation for the last move applied to the given game state
// if "undo" is set to NO, the move is applied to the board
// if "undo" is set to YES, the reverse move is applied to the board
// after the animation is done, the block is invoked (asnychronously!)
- (void)animateLastMoveOfGameState:(JCSFlipGameState *)gameState undo:(BOOL)undo afterAnimationInvokeBlock:(void(^)())block;

// repeatedly flash a cell
// restarts flashing if the cell is already flashing
- (void)startFlashForCellAtRow:(NSInteger)row column:(NSInteger)column;

// stops the cell's flashing
// no-op if the cell is not flashing
- (void)stopFlashForCellAtRow:(NSInteger)row column:(NSInteger)column;

// properly cancel any move input that might be in progress
- (void)cancelMoveInput;

@end
