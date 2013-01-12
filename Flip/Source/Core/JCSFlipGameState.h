//
//  JCSFlipGameState.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"
#import "JCSFlipCellState.h"

@class JCSFlipMove;

// state information for a running game
@interface JCSFlipGameState : NSObject <NSCoding>

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

// initialize a default board with the given size
// the board is a hexagon, using the given size as edge length
// it is player A's turn
// there is a hole at (0,0), player A owns (-1,0), (0,-1), and (1,-1), while player B owns (-1,1), (0,1), and (1,0)
- (id)initDefaultWithSize:(NSInteger)size;

// invoke the block for all cells, including holes
// iteration stops prematurely when the block sets *stop to YES
- (void)forAllCellsInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop))block;

// determines the state of the cell at the given coordinate
- (JCSFlipCellState)cellStateAtRow:(NSInteger)row column:(NSInteger)column;

// applies the move, switches players, and returns YES if the move is legal
// returns NO if the move is illegal
// for legal moves, the move is pushed onto an internal stack and can be undone with -popMove
- (BOOL)pushMove:(JCSFlipMove *)move;

// un-applies the last successfully applied move
// the move is removed from the internal stack
// the internal move stack must be non-empty
- (void)popMove;

// invoke the block for cells who were involved in the last move applied with -pushMove: and not undone with -popMove
// the block is invoked for the starting cell, the flipped cells (in move direction) and the target cell, in that order
// iteration stops prematurely when the block sets *stop to YES
// the internal move stack must be non-empty
- (void)forAllCellsInvolvedInLastMoveInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop))block;

// let the other player win
// returns YES if successful
// returns NO if the game has already been over
- (BOOL)resign;

// iterate over all valid moves for the receiving game state
// each move is applied to the receiver, the block is invoked, and the move is unapplied from the receiver
// iteration stops prematurely when the block sets *stop to YES
// a new move instance is passed to each invocation of the block
- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(JCSFlipMove *move, BOOL *stop))block;

// encode the receiver into the given NSCoder instance, optionally including the move stack
// the decoding method is provided by the NSCoding protocol
// the encoding method from the NSCoding protocol includes the move stack
- (void)encodeWithCoder:(NSCoder *)aCoder includeMoveStack:(BOOL)includeMoveStack;

@end
