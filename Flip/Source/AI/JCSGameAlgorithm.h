//
//  JCSGameAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@protocol JCSGameNode;

@protocol JCSGameAlgorithm

// determine the move to be chosen at the given node
// returns nil if there is no possible move
- (id)moveAtNode:(id<JCSGameNode>)node;

@end
