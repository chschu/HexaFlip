//
//  JCSFlipGameStatePossessionHeuristic.h
//  HexaFlip
//
//  Created by Christian Schuster on 14.08.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameHeuristic.h"

// Possession heuristic for instances of JCSFlipGameState
//
// this heuristic uses the number of cells owned by each player
//
// for finished games, its value is 10^20 * (cells owned by A - cells owned by B)
// it uses this "near infinity" values to reach the best score even when the outcome is already certain
//
// for running games, its value is (cells owned by A - cells owned by B)
@interface JCSFlipGameStatePossessionHeuristic : NSObject <JCSGameHeuristic>

@end
