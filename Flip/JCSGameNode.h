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

// enumerate the child nodes of the receiver, passing move data and the child node to the given block
// enumeration stops when the block sets *stop to YES
- (void)enumerateChildrenUsingBlock:(void(^)(id move, id<JCSGameNode> child, BOOL *stop))block;

@end
