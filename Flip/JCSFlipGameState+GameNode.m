//
//  JCSFlipGameState+GameNode.m
//  Flip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState+GameNode.h"

@implementation JCSFlipGameState (GameNode)

NSInteger _callCount = 0;

- (float)heuristicValue {
    __block float score;
    if (++_callCount % 100000 == 0) {
        NSLog(@"heuristicValue called %d times", _callCount);
    }
    
	switch (self.status) {
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
            
            // a player's cell is considered "safe" for a direction if and only if at least one of the following is true:
            // - all cells in the direction (up to the next hole) are owned by the player
            // - there is no empty cell in the opposing direction (up to the next hole)
            
            // a player's cell that is safe for x directions scores 1+x points
            
            // the total heuristic score is the difference of player A's and player B's scores
            
            [self forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
                if (cellState == JCSFlipCellStateOwnedByPlayerA || cellState == JCSFlipCellStateOwnedByPlayerB) {
                    // start with a base score of 1, add 1 for every safe direction
                    NSInteger cellScore = 1;
                    for (JCSHexDirection dir = JCSHexDirectionMin; dir <= JCSHexDirectionMax; dir++) {
                        NSInteger rowDelta = JCSHexDirectionRowDelta(dir);
                        NSInteger columnDelta = JCSHexDirectionColumnDelta(dir);
                        
                        NSInteger curRow;
                        NSInteger curColumn;
                        JCSFlipCellState curState;
                        
                        // check 1: all cells in the direction (up to the next hole) are owned by the player
                        
                        curRow = row + rowDelta;
                        curColumn = column + columnDelta;
                        while ((curState = [self cellStateAtRow:curRow column:curColumn]) == cellState) {
                            curRow += rowDelta;
                            curColumn += columnDelta;
                        }
                        if (curState == JCSFlipCellStateHole) {
                            // direction is safe
                            cellScore++;
                            continue;
                        }
                        
                        // check 2: there is no empty cell in the opposing direction (up to the next hole)
                        
                        curRow = row - rowDelta;
                        curColumn = column - columnDelta;
                        while ((curState = [self cellStateAtRow:curRow column:curColumn]) == JCSFlipCellStateOwnedByPlayerA || curState == JCSFlipCellStateOwnedByPlayerB) {
                            curRow -= rowDelta;
                            curColumn -= columnDelta;
                        }
                        if (curState != JCSFlipCellStateEmpty) {
                            // direction is safe
                            cellScore++;
                        }
                    }
                    
                    // cell scoring: a player's cell that is safe for x directions scores 1+x points
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

- (BOOL)leaf {
    return !(self.status == JCSFlipGameStatusPlayerAToMove || self.status == JCSFlipGameStatusPlayerBToMove);
}

- (BOOL)maximizing {
    return self.status == JCSFlipGameStatusPlayerAToMove;
}

- (void)enumerateChildrenUsingBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block {
    [self forAllNextStatesInvokeBlock:block];
}

/*
 - (NSString *)description {
 NSMutableString *desc = [NSMutableString stringWithFormat:@"%d", self.status];
 
 [self forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
 if (cellState == JCSFlipCellStateEmpty) {
 [desc appendString:@"X"];
 } else if (cellState == JCSFlipCellStateOwnedByPlayerA) {
 [desc appendString:@"A"];
 } else if (cellState == JCSFlipCellStateOwnedByPlayerB) {
 [desc appendString:@"B"];
 }
 }];
 
 return [desc copy];
 }
 */

@end
