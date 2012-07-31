//
//  JCSFlipGameStatePossessionSafetyHeuristic.h
//  Flip
//
//  Created by Christian Schuster on 31.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameHeuristic.h"

// heuristic implementation for instances of JCSFlipGameState
// this heuristic uses the number of cells owned by each player, and the "safety" degrees of each of these cells
//
// for finished games, its value is INFINITY (A won), -INFINITY (B won), or 0 (draw)
//
// for running games, its value is determined in the following way:
//
// a player's cell is considered "safe" for a direction if and only if at least one of the following is true:
// - all cells in the direction (up to the next hole) are owned by the player
// - there is no empty cell in the opposing direction (up to the next hole)
//
// a player's cell that is safe for x directions scores p+(x/6)*s points, where p is the "possession" factor, while s is the "safety" factor
// so the maximum score of a cell is p+q
//
// cell scores of player A are added to the final score, cell scores of B are subtracted from the final score
@interface JCSFlipGameStatePossessionSafetyHeuristic : NSObject <JCSGameHeuristic>

- (id)initWithPossession:(float)possession safety:(float)safety;

@end
