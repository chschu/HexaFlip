//
//  JCSGameHeuristic.h
//  HexaFlip
//
//  Created by Christian Schuster on 31.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@protocol JCSGameNode;

// protocol for heuristic evaluation of game nodes
@protocol JCSGameHeuristic

// compute a heuristic value of the node
// larger values mean an advantage for the player about to move
// if the node is a leaf, the "player about to move" is the player that would be about to move if the leaf was no node
- (float)valueOfNode:(id<JCSGameNode>)node;

@end
