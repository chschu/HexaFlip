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
    switch (node.status) {
		case JCSFlipGameStatusPlayerAWon:
		case JCSFlipGameStatusPlayerBWon:
		case JCSFlipGameStatusDraw:
            return 1e20 * (node.cellCountPlayerA-node.cellCountPlayerB);
		default:
            return node.cellCountPlayerA-node.cellCountPlayerB;
    }
}

@end
