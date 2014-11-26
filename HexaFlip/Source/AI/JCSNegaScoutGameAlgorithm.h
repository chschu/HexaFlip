//
//  JCSNegaScoutGameAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 22.10.13.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSGameAlgorithmBase.h"

@protocol JCSGameHeuristic;

@interface JCSNegaScoutGameAlgorithm : JCSGameAlgorithmBase <JCSGameAlgorithm>

// initialize with the given search depth and a heuristic evaluation function
// the heuristic is assumed to return larger values if there is an advantage for the player about to move
- (instancetype)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic;

@end
