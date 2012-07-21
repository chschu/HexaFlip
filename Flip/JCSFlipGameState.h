//
//  JCSFlipGameState.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"
#import "JCSHexCoordinate.h"
#import "JCSFlipMove.h"
#import "JCSFlipCellState.h"

// state information for a running game
@interface JCSFlipGameState : NSObject <NSCopying>

// the player to move
@property (readonly) JCSFlipPlayer playerToMove;

// initialize with given size
// the block for all pairs of rows and columns in [-size,size]
// a cell is present in the board iff the cellsAtBlock returns YES
// the state of a cell is determined by the cellStateAtBlock
// size must be non-negative, and none of the blocks may be nil
- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayer)playerToMove cellAtBlock:(BOOL(^)(JCSHexCoordinate *coordinate))cellAtBlock cellStateAtBlock:(JCSFlipCellState(^)(JCSHexCoordinate *coordinate))cellStateAtBlock;

// invoke the block for all cells
// iteration stops when the block sets *stop to YES
- (void)forAllCellsInvokeBlock:(void(^)(JCSHexCoordinate *coordinate, JCSFlipCellState cellState, BOOL *stop))block;

// determines if there is a cell at the given coordinate
- (BOOL)hasCellAt:(JCSHexCoordinate *)coordinate;

// determines the state of the cell at the given coordinate
// throws an exception if there is no such cell
- (JCSFlipCellState)cellStateAt:(JCSHexCoordinate *)coordinate;

// applies move, switches players, and returns YES if the move is legal 
// returns NO if the move is illegal 
- (BOOL)applyMove:(JCSFlipMove *)move;

// iterate over all possible moves leading away from the game state (for AI algorithms)
// the move and the successor state is passed to the given block
// iteration stops when the block sets *stop to YES
- (void)forAllNextStatesInvokeBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block;

@end
