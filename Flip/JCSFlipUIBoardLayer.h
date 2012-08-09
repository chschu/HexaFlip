//
//  JCSFlipUIBoardLayer.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"
#import "JCSFlipCellState.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMoveInputDelegate.h"
#import "JCSFlipUICellNodeTouchDelegate.h"

#import "cocos2d.h"

// the layer displaying the current board
@interface JCSFlipUIBoardLayer : CCNode <JCSFlipUICellNodeTouchDelegate>

// the delegate for forward input information to
@property (weak, nonatomic) id<JCSFlipMoveInputDelegate> inputDelegate;

// is local move input enabled (NO by default)
@property (nonatomic) BOOL moveInputEnabled;

// initializes the view with the given game state
- (id)initWithState:(JCSFlipGameState *)state;

// asynchronously start an animation for the given move, using the moveInfo to determine the modified cells
// the moveInfo must have been populated before, by passing it when the move is applied
// after the animation is done, the block is invoked (asnychronously!)
- (void)animateMove:(JCSFlipMove *)move moveInfo:(id)moveInfo newGameState:(JCSFlipGameState *)newGameState afterAnimationInvokeBlock:(void(^)())block;

// repeatedly flash a cell
// restarts flashing if the cell is already flashing
- (void)startFlashForCellAtRow:(NSInteger)row column:(NSInteger)column;

// stops the cell's flashing
// no-op if the cell is not flashing
- (void)stopFlashForCellAtRow:(NSInteger)row column:(NSInteger)column;
    
@end
