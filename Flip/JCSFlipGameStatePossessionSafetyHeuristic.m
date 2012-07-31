//
//  JCSFlipGameStatePossessionSafetyHeuristic.m
//  Flip
//
//  Created by Christian Schuster on 31.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatePossessionSafetyHeuristic.h"
#import "JCSFlipGameState.h"
#import "JCSFlipGameState+GameNode.h"

@implementation JCSFlipGameStatePossessionSafetyHeuristic {
    float _possession;
    float _safety;
}

- (id)initWithPossession:(float)possession safety:(float)safety {
    if (self = [super init]) {
        _possession = possession;
        _safety = safety;
    }
    return self;
}

- (float)valueOfNode:(JCSFlipGameState *)node {
    __block float score;
    switch (node.status) {
		case JCSFlipGameStatusPlayerAWon:
			score = INFINITY;
            break;
		case JCSFlipGameStatusPlayerBWon:
            score = -INFINITY;
            break;
		case JCSFlipGameStatusDraw:
            score = 0;
            break;
		default:
            score = 0;
            [node forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
                if (cellState == JCSFlipCellStateOwnedByPlayerA || cellState == JCSFlipCellStateOwnedByPlayerB) {
                    // start with a base possession score, add safety/6 for every safe direction
                    float cellScore = _possession;
                    for (JCSHexDirection dir = JCSHexDirectionMin; dir <= JCSHexDirectionMax; dir++) {
                        NSInteger rowDelta = JCSHexDirectionRowDelta(dir);
                        NSInteger columnDelta = JCSHexDirectionColumnDelta(dir);
                        
                        NSInteger curRow;
                        NSInteger curColumn;
                        JCSFlipCellState curState;
                        
                        // check 1: all cells in the direction (up to the next hole) are owned by the player
                        
                        curRow = row + rowDelta;
                        curColumn = column + columnDelta;
                        while ((curState = [node cellStateAtRow:curRow column:curColumn]) == cellState) {
                            curRow += rowDelta;
                            curColumn += columnDelta;
                        }
                        if (curState == JCSFlipCellStateHole) {
                            // direction is safe
                            cellScore += _safety/6;
                            continue;
                        }
                        
                        // check 2: there is no empty cell in the opposing direction (up to the next hole)
                        
                        curRow = row - rowDelta;
                        curColumn = column - columnDelta;
                        while ((curState = [node cellStateAtRow:curRow column:curColumn]) == JCSFlipCellStateOwnedByPlayerA || curState == JCSFlipCellStateOwnedByPlayerB) {
                            curRow -= rowDelta;
                            curColumn -= columnDelta;
                        }
                        if (curState != JCSFlipCellStateEmpty) {
                            // direction is safe
                            cellScore += _safety/6;
                        }
                    }
                    
                    // add or subtract cell score from total, depending on owner
                    if (cellState == JCSFlipCellStateOwnedByPlayerA) {
                        score += cellScore;
                    } else {
                        score -= cellScore;
                    }
                }
            }];
    }
    return score;
}

@end
