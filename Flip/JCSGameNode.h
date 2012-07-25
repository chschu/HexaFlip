//
//  JCSGameNode.h
//  Flip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// a node in a two-player zero-sum game tree
@protocol JCSGameNode

// the heuristic value of the receiving node
@property (readonly) float heuristicValue;

// whether the receiver is a maximizing node
@property (readonly) BOOL maximizing;

// enumerate the child nodes of the receiver, passing move data and the child node to the given block
// enumeration stops when the block sets *stop to YES
- (void)enumerateChildrenUsingBlock:(void(^)(id move, id<JCSGameNode> child, BOOL *stop))block;

@end
