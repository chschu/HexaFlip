//
//  JCSGameNode.h
//  HexaFlip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// a node in a two-player zero-sum game tree
@protocol JCSGameNode

// whether the receiver is a leaf node
@property (readonly, nonatomic) BOOL leaf;

// Zobrist hash value of the receiver
// can be used as key for transposition tables
@property (readonly, nonatomic) NSUInteger zobristHash;

// iterate over all valid moves for the receiving game state
// each move is applied to the receiver, the block is invoked, and the move is unapplied from the receiver
// iteration stops prematurely when the block returns NO
// a new move instance is passed to each invocation of the block
// special case: if two or more moves lead to the same game state, only one of them is considered
- (void)applyAllPossibleMovesAndInvokeBlock:(BOOL(^)(id move))block;

// applies the move, switches players, and returns YES if the move is legal
// returns NO if the move is illegal
// for legal moves, the move is pushed onto an internal stack and can be undone with -popMove
- (BOOL)pushMove:(id)move;

// un-applies the last successfully applied move
// the move is removed from the internal stack
// the internal move stack must be non-empty
- (void)popMove;

@end
