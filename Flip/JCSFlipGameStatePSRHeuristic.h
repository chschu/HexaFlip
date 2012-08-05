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
// as well as a pseudo-random base score to make gameplay somewhat non-deterministic
//
// for finished games, its value is 10^20 * (cells owned by A - cells owned by B)
// it uses this "near infinity" values to reach the best score even when the outcome is already certain
//
// for running games, its value is determined in the following way:
//
// a player's cell is considered "safe" for a direction if and only if at least one of the following is true:
// - all cells in the direction (up to the next hole) are owned by the player
// - there is no empty cell in the opposing direction (up to the next hole)
//
// a cell score is the sum of two parts
// - a possession value P; p is the "possession" value passed to init
// - a safety value (x/6)*S; S is the "safety" value passed to the initializer, x is the number of safe directions for the cell
//
// cell scores of player A are added to the final score, cell scores of B are subtracted from the final score
//
// a random value R in the range [-r,r] is added to the sum of the cell scores score, where r is the "randomness" value
// passed to the initializer. the value of R only depends on the "randomness" value and the game state's hash value.
//
// the final heuristic value is R + sum[P+(x(c)/6)*S, for all cells c of player A] - sum[P+(x(c)/6)*S, for all cells c of player B]
@interface JCSFlipGameStatePSRHeuristic : NSObject <JCSGameHeuristic>

// initialize with given "possession", "safety", and "randomness" values
- (id)initWithPossession:(float)possession safety:(float)safety randomness:(float)randomness;

@end
