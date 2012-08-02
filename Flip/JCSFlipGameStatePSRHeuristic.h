//
//  JCSFlipGameStatePossessionSafetyHeuristic.h
//  Flip
//
//  Created by Christian Schuster on 31.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameHeuristic.h"

// Possession-Safety-Randomness heuristic for instances of JCSFlipGameState
//
// this heuristic uses the number of cells owned by each player, and the "safety" degrees of each of these cells,
// as well as a randomness score to make gameplay somewhat non-deterministic
//
// for finished games, its value is INFINITY (A won), -INFINITY (B won), or 0 (draw)
//
// for running games, its value is determined in the following way:
//
// a player's cell is considered "safe" for a direction if and only if at least one of the following is true:
// - all cells in the direction (up to the next hole) are owned by the player
// - there is no empty cell in the opposing direction (up to the next hole)
//
// a cell score is the sum of three parts
// - a possession value p; p is the "possession" value passed to init
// - a safety value (x/6)*s; s is the "safety" value passed to init, x is the number of safe directions for the cell
// - a randomness value in the range [0,r], which is determined once per board; r is the "randomness" value passed to init
//
// cell scores of player A are added to the final score, cell scores of B are subtracted from the final score
@interface JCSFlipGameStatePSRHeuristic : NSObject <JCSGameHeuristic>

// initialize with given "possession", "safety", and "randomness" values
- (id)initWithPossession:(float)possession safety:(float)safety randomness:(float)randomness;

@end
