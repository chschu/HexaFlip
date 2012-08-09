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
@interface JCSFlipGameState : NSObject

// the current game status
@property (readonly, nonatomic) JCSFlipGameStatus status;

// number of cells owned by player A
@property (readonly, nonatomic) NSInteger cellCountPlayerA;

// number of cells owned by player B
@property (readonly, nonatomic) NSInteger cellCountPlayerB;

// number of empty cells
@property (readonly, nonatomic) NSInteger cellCountEmpty;

// flag indicating if skipping is allowed
@property (readonly, nonatomic) BOOL skipAllowed;

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

// allocate and initialize a moveInfo memento instance, to be passed to -applyMove:moveInfo: and -unapplyMove:moveInfo:
- (id)newMoveInfo;

// applies the move, switches players, and returns YES if the move is legal
// returns NO if the move is illegal
// for legal moves, the moveInfo is populated and can be passed to -unapplyMove:moveInfo: later on
// if moveInfo is nil, the move information is simply discarded
- (BOOL)applyMove:(JCSFlipMove *)move moveInfo:(id)moveInfo;

// un-applies the move, using the information stored in moveInfo by -applyMove:moveInfo:
// the move must be the last one applied to the receiver
// moveInfo must not be nil
- (void)unapplyMove:(JCSFlipMove *)move moveInfo:(id)moveInfo;

// invoke the block for cells whose states were changed by the move, using the information stored in moveInfo by -applyMove:moveInfo:
// the first invocation of the block is for the cell closest to the starting cell of the move
// the last invocation of the block is for the cell that was occupied (not flipped) by the move
// the move must be the last one applied to the receiver
// moveInfo must not be nil
// iteration stops when the block sets *stop to YES
- (void)forAllCellsChangedByMove:(JCSFlipMove *)move moveInfo:(id)moveInfo invokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState newCellState, BOOL *stop))block;

// let the other player win
// returns YES if successful
// returns NO if the game has already been over
- (BOOL)resign;

// iterate over all valid moves for the receiving game state
// each move is applied to the receiver, the block is invoked, and the move is unapplied from the receiver
// iteration stops when the block sets *stop to YES
// a new move instance is passed to each invocation of the block
- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(JCSFlipMove *move, BOOL *stop))block;

@end
