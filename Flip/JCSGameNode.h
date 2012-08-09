//
//  JCSGameNode.h
//  Flip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// a node in a two-player zero-sum game tree
@protocol JCSGameNode <NSObject>

// whether the receiver is a leaf node
@property (readonly, nonatomic) BOOL leaf;

// whether the receiver is a maximizing node
@property (readonly, nonatomic) BOOL maximizing;

// iterate over all valid moves for the receiver
// each move is applied to the receiver, the block is invoked, and the move is unapplied from the receiver
// iteration stops when the block sets *stop to YES
// a new move instance is passed to each invocation of the block
- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(id move, BOOL *stop))block;

// allocate and initialize a moveInfo memento instance, to be passed to -applyMove:moveInfo: and -unapplyMove:moveInfo:
- (id)newMoveInfo;

// applies the move, switches players, and returns YES if the move is legal
// returns NO if the move is illegal
// for legal moves, the moveInfo is populated and can be passed to -unapplyMove:moveInfo: later on
// if moveInfo is nil, the move information is simply discarded
- (BOOL)applyMove:(id)move moveInfo:(id)moveInfo;

// un-applies the move, using the information stored in moveInfo by -applyMove:moveInfo:
// the move must be the last one applied to the receiver
// moveInfo must not be nil
- (void)unapplyMove:(id)move moveInfo:(id)moveInfo;

@end
