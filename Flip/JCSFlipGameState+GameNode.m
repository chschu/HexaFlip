//
//  JCSFlipGameState+GameNode.m
//  Flip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState+GameNode.h"

@implementation JCSFlipGameState (GameNode)

- (float)heuristicValue {
	switch (self.status) {
		case JCSFlipGameStatusPlayerAWon:
			return INFINITY;
		case JCSFlipGameStatusPlayerBWon:
			return -INFINITY;
		case JCSFlipGameStatusDraw:
			return 0;
		default:
            return self.cellCountPlayerA - self.cellCountPlayerB;
    }
}

- (BOOL)maximizing {
    return self.status == JCSFlipGameStatusPlayerAToMove;
}

- (void)enumerateChildrenUsingBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block {
    [self forAllNextStatesInvokeBlock:block];
}

@end
