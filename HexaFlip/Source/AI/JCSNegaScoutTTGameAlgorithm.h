//
//  JCSNegaScoutTTGameAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"

@protocol JCSGameHeuristic;

@interface JCSNegaScoutTTGameAlgorithm : NSObject <JCSGameAlgorithm>

// initialize with the given search depth, heuristic evaluation function, and number of slots in the transposition table
// the heuristic is assumed to return larger values if there is an advantage for the player about to move
- (id)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic transpositionTableSize:(NSUInteger)transpositionTableSize;

@end
