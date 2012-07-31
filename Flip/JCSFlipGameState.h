//
//  JCSFlipGameState.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"
#import "JCSFlipMove.h"
#import "JCSFlipCellState.h"

// state information for a running game
@interface JCSFlipGameState : NSObject <NSCopying>

// the current game status
@property (readonly) JCSFlipGameStatus status;

// number of cells owned by player A
@property (readonly) NSInteger cellCountPlayerA;

// number of cells owned by player B
@property (readonly) NSInteger cellCountPlayerB;

// number of empty cells
@property (readonly) NSInteger cellCountEmpty;

// flag indicating if skipping is allowed
@property (readonly) BOOL skipAllowed;

// initialize with given size
// status defines which player moves first
// the cellStateAtBlock is invoked for all pairs of rows and columns between -(size-1) and (size-1), both inclusive
// the state of a cell is returned by the cellStateAtBlock
// size must be non-negative, and none of the blocks may be nil
- (id)initWithSize:(NSInteger)size status:(JCSFlipGameStatus)status cellStateAtBlock:(JCSFlipCellState(^)(NSInteger row, NSInteger column))cellStateAtBlock;

// invoke the block for all cells, including holes
// iteration stops when the block sets *stop to YES
- (void)forAllCellsInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop))block;

// determines the state of the cell at the given coordinate
- (JCSFlipCellState)cellStateAtRow:(NSInteger)row column:(NSInteger)column;

// applies move, switches players, and returns YES if the move is legal 
// returns NO if the move is illegal 
- (BOOL)applyMove:(JCSFlipMove *)move;

// let the other player win
// returns YES if successful
// returns NO if the game has already been over
- (BOOL)resign;

// iterate over all possible moves leading away from the game state
// the move and the successor state is passed to the given block
// iteration stops when the block sets *stop to YES
- (void)forAllNextStatesInvokeBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block;

@end
