//
//  JCSFlipGameStatePossessionHeuristic.m
//  HexaFlip
//
//  Created by Christian Schuster on 14.08.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatePossessionHeuristic.h"
#import "JCSFlipGameState.h"

@implementation JCSFlipGameStatePossessionHeuristic

- (float)valueOfNode:(JCSFlipGameState *)node {
    float score;
    switch (node.status) {
		case JCSFlipGameStatusPlayerAWon:
		case JCSFlipGameStatusPlayerBWon:
		case JCSFlipGameStatusDraw:
            if (node.cellCountPlayerA == 0) {
                score = -INFINITY;
            } else if (node.cellCountPlayerB == 0) {
                score = INFINITY;
            } else {
                score = 1e20 * (node.cellCountPlayerA-node.cellCountPlayerB);
            }
		default:
            score = node.cellCountPlayerA-node.cellCountPlayerB;
    }
    return score;
}

@end
