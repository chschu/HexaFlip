//
//  JCSFlipGameState.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"
#import "JCSFlipMove.h"
#import "JCSFlipCellState.h"

// state information for a running game
@interface JCSFlipGameState : NSObject <NSCopying>

// the player to move
@property (readonly) JCSFlipPlayer playerToMove;

// initialize with given size
// the cellStateAtBlock is invoked for all pairs of rows and columns between -(size-1) and (size-1), both inclusive
// the state of a cell is returned by the cellStateAtBlock
// size must be non-negative, and none of the blocks may be nil
- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayer)playerToMove cellStateAtBlock:(JCSFlipCellState(^)(NSInteger row, NSInteger column))cellStateAtBlock;

// invoke the block for all non-hole cells
// iteration stops when the block sets *stop to YES
- (void)forAllCellsInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop))block;

// determines the state of the cell at the given coordinate
- (JCSFlipCellState)cellStateAtRow:(NSInteger)row column:(NSInteger)column;

// applies move, switches players, and returns YES if the move is legal 
// returns NO if the move is illegal 
- (BOOL)applyMove:(JCSFlipMove *)move;

// iterate over all possible moves leading away from the game state (for AI algorithms)
// the move and the successor state is passed to the given block
// iteration stops when the block sets *stop to YES
- (void)forAllNextStatesInvokeBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block;

@end
