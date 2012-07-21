//
//  JCSFlipAlgoTest.m
//  Flip
//
//  Created by Christian Schuster on 20.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMinimax.h"
#import "JCSHexCoordinate.h"
#import "JCSFlipCellState.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"

@interface JCSFlipAlgoTest : SenTestCase
@end

@implementation JCSFlipAlgoTest

- (void) testSomething {
    int size = 4;
    
    BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
        NSInteger distanceFromOrigin = [coordinate distanceTo:[JCSHexCoordinate hexCoordinateForOrigin]];
        return distanceFromOrigin > 0 && distanceFromOrigin < size;
    };
    
    JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
        if ([coordinate distanceTo:[JCSHexCoordinate hexCoordinateForOrigin]] == 1) {
            if (coordinate.row + 2*coordinate.column < 0) {
                return JCSFlipCellStateOwnedByPlayerA;
            } else {
                return JCSFlipCellStateOwnedByPlayerB;
            }
        } else {
            return JCSFlipCellStateEmpty;
        }
    };
    
    JCSFlipGameState *state = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];
    
    while (true) {
        NSInteger depth = state.playerToMove == JCSFlipPlayerA ? 3 : 2;
        JCSFlipMove *move = [JCSFlipMinimax bestMoveForState:state depth:depth];
        if (move == nil) {
            break;
        }
        NSLog(@"executing move %d,%d %d", move.start.row, move.start.column, move.direction);
        [state applyMove:move];
        
        for (int row = size-1; row >= -(size-1); row--) {
            NSMutableString *line = [NSMutableString string];
            for (int i = 0; i < abs(row); i++) {
                [line appendString:@" "];
            }
            for (int col = MAX(-(size-1),-(size-1)-row); col <= MIN(size-1,(size-1)-row); col++) {
                char c;
                JCSHexCoordinate *coord = [JCSHexCoordinate hexCoordinateWithRow:row column:col];
                if ([state hasCellAt:coord]) {
                JCSFlipCellState cellState = [state cellStateAt:coord];
                    if (cellState == JCSFlipCellStateOwnedByPlayerA) {
                        c = 'A';
                    } else if (cellState == JCSFlipCellStateOwnedByPlayerB) {
                        c = 'B';
                    } else {
                        c = '.';
                    }
                } else {
                    c = ' ';
                }
                [line appendFormat:@"%c ", c];
            }
            NSLog(@"%@", line);
        }
        
    }
    NSLog(@"done");
}

@end
