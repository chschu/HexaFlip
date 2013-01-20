//
//  JCSMinimaxAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 21.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"

@protocol JCSGameHeuristic;

@interface JCSMinimaxGameAlgorithm : NSObject <JCSGameAlgorithm>

@property (readonly, nonatomic) NSInteger depth;

// initialize with the given search depth and a heuristic evaluation function
// the heuristic is assumed to return larger values if there is an advantage for player A
// the heuristic is assumed to return smaller values if there is an advantage for player B
- (id)initWithDepth:(NSInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic;

@end
