//
//  JCSNegaScoutTTGameAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSGameAlgorithmBase.h"
#import "JCSTranspositionTable.h"

@protocol JCSGameHeuristic;

@interface JCSNegaScoutTTGameAlgorithm : JCSGameAlgorithmBase <JCSGameAlgorithm>

// initialize with the given search depth, heuristic evaluation function, and (possibly pre-populated) transposition table
// the heuristic is assumed to return larger values if there is an advantage for the player about to move
- (instancetype)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic transpositionTable:(JCSTranspositionTable *)transpositionTable;

@end
