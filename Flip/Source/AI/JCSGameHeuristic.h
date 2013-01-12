//
//  JCSGameHeuristic.h
//  Flip
//
//  Created by Christian Schuster on 31.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@protocol JCSGameNode;

// protocol for heuristic evaluation of game nodes
@protocol JCSGameHeuristic <NSObject>

- (float)valueOfNode:(id<JCSGameNode>)node;

@end
