//
//  JCSGameAlgorithmBase.h
//  HexaFlip
//
//  Created by Christian Schuster on 27.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

@protocol JCSGameNode;
@protocol JCSMove;

// partial implementation of the JCSGameAlgorithm protocol
@interface JCSGameAlgorithmBase : NSObject

// YES if and only if -cancel has been invoked, possibly from another thread
@property (atomic, readonly) BOOL canceled;

// apply each possible move to the given node, then invoke the given valueProvider to determine a value for each move, and unapply the move again
// the results are then sorted by the determined value (increasing)
// from the sorted result, each move is applied to the node, then the given block is invoked, and the move is unapplied again
// if the block returns NO, no more moves are processed from the sorted result
// if the algorithm is canceled, this method should return as soon as possible
- (void)applyPossibleMovesToNode:(id<JCSGameNode>)node sortByValue:(float(^)(id move))valueProvider invokeBlock:(BOOL(^)(id move))block;

// common implementation of the -cancel method
// sets the canceled property to YES
- (void)cancel;

@end
