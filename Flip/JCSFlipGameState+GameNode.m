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
    __block float score = 0;
    __block BOOL hasEmptyCells = NO;
    [self forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        if (cellState != JCSFlipCellStateEmpty) {
            if (cellState == JCSFlipCellStateOwnedByPlayerA) {
                score++;
            } else if (cellState == JCSFlipCellStateOwnedByPlayerB) {
                score--;
            }
        } else {
            hasEmptyCells = YES;
        }
    }];
    
    // if there are no empty cells, we have a clear winner
    if (!hasEmptyCells) {
        if (score > 0) {
            // A wins
            score = INFINITY;
        } else if (score < 0) {
            // B wins
            score = -INFINITY;
        }
    }
    
    return score;
}

- (BOOL)maximizing {
    return self.status == JCSFlipGameStatusPlayerAToMove;
}

- (void)enumerateChildrenUsingBlock:(void(^)(id move, id<JCSGameNode> child, BOOL *stop))block {
    [self forAllNextStatesInvokeBlock:^(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop) {
        block(move, nextState, stop);
    }];
}

@end
