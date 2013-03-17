//
//  JCSFlipGameState.h
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"
#import "JCSFlipPlayerToMove.h"
#import "JCSFlipCellState.h"
#import "JCSGameNode.h"

@class JCSFlipMove;

// state information for a running game
@interface JCSFlipGameState : NSObject <NSCoding, JCSGameNode>

// the current game status
@property (readonly, nonatomic) JCSFlipGameStatus status;

// the current player to move (also set if the game is over)
@property (readonly, nonatomic) JCSFlipPlayerToMove playerToMove;

// number of cells owned by player A
@property (readonly, nonatomic) NSInteger cellCountPlayerA;

// number of cells owned by player B
@property (readonly, nonatomic) NSInteger cellCountPlayerB;

// number of empty cells
@property (readonly, nonatomic) NSInteger cellCountEmpty;

// flag indicating if skipping is allowed
@property (readonly, nonatomic) BOOL skipAllowed;

// the last move, or nil if there is none, or it is not known (e.g. because the move stack has been discarded)
@property (readonly, nonatomic) JCSFlipMove *lastMove;

// is the move stack empty?
@property (readonly, nonatomic) BOOL moveStackEmpty;

// initialize with given size
// playerToMove defines which player moves first
// the cellStateAtBlock is invoked for all pairs of rows and columns between -(size-1) and (size-1), both inclusive
// the state of a cell is returned by the cellStateAtBlock
// size must be non-negative, and none of the blocks may be nil
- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayerToMove)playerToMove cellStateAtBlock:(JCSFlipCellState(^)(NSInteger row, NSInteger column))cellStateAtBlock;

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

// invoke the block for cells who were involved in the last move applied with -pushMove: and not undone with -popMove
// the block is invoked for the starting cell, the flipped cells (in move direction) and the target cell, in that order
// iteration stops prematurely when the block sets *stop to YES
// the internal move stack must be non-empty
- (void)forAllCellsInvolvedInLastMoveInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop))block;

// encode the receiver using the given NSCoder instance
// the maximum number of moves is defined by the "maxMoves" parameter
// the decoding method is provided by the NSCoding protocol
// the encoding method from the NSCoding protocol includes the full move stack
- (void)encodeWithCoder:(NSCoder *)aCoder maxMoves:(NSUInteger)maxMoves;

@end
