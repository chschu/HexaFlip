//
//  JCSGameNode.h
//  HexaFlip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// a node in a two-player zero-sum game tree
@protocol JCSGameNode <NSObject>

// whether the receiver is a leaf node
@property (readonly, nonatomic) BOOL leaf;

// iterate over all valid moves for the receiver
// each move is applied to the receiver, the block is invoked, and the move is unapplied from the receiver
// iteration stops prematurely when the block sets *stop to YES
// a new move instance is passed to each invocation of the block
- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(id move, BOOL *stop))block;

// applies the move, switches players, and returns YES if the move is legal
// returns NO if the move is illegal
// for legal moves, the move is pushed onto an internal stack and can be undone with -popMove
- (BOOL)pushMove:(id)move;

// un-applies the last successfully applied move
// the move is removed from the internal stack
// the internal move stack must be non-empty
- (void)popMove;

@end
