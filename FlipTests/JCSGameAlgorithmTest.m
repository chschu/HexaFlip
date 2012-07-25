//
//  JCSFlipAlgoTest.m
//  Flip
//
//  Created by Christian Schuster on 20.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSRandomGameAlgorithm.h"
#import "JCSFlipCellState.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameState+GameNode.h"

@interface JCSFlipAlgoTest : SenTestCase
@end

@implementation JCSFlipAlgoTest

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) (MAX(MAX(abs((r1)-(r2)), abs((c1)-(c2))), abs((0-(r1)-(c1))-(0-(r2)-(c2)))))

- (void)testMinimax2VsMinimax3 {
    id<JCSGameAlgorithm> algoA = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:2];
    id<JCSGameAlgorithm> algoB = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:1];
    int size = 5;
    [self testAlgorithm:algoA againstAlgorithm:algoB withBoardSize:size];
}

- (void)testMinimax2VsRandom {
    id<JCSGameAlgorithm> algoA = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:1];
    id<JCSGameAlgorithm> algoB = [[JCSRandomGameAlgorithm alloc] initWithSeed:time(NULL)];
    int size = 4;
    [self testAlgorithm:algoA againstAlgorithm:algoB withBoardSize:size];
}

- (void)testAlgorithm:(id<JCSGameAlgorithm>)algoA againstAlgorithm:(id<JCSGameAlgorithm>)algoB withBoardSize:(NSInteger)size {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        NSInteger distanceFromOrigin = JCS_HEX_DISTANCE(row, column, 0, 0);
        if (distanceFromOrigin == 0 || distanceFromOrigin >= size) {
            return JCSFlipCellStateHole;
        } else if (distanceFromOrigin == 1) {
            if (row + 2*column < 0) {
                return JCSFlipCellStateOwnedByPlayerA;
            } else {
                return JCSFlipCellStateOwnedByPlayerB;
            }
        } else {
            return JCSFlipCellStateEmpty;
        }
    };

    JCSFlipGameState *state = [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    while (true) {
        id<JCSGameAlgorithm> algo = (state.status == JCSFlipGameStatusPlayerAToMove ? algoA : algoB);
        
        JCSFlipMove *move = [algo moveAtNode:state];
        if (move == nil) {
            break;
        }

        [state applyMove:move];
        
        NSLog(@"\n%@", state);
    }
    NSLog(@"done");

    STAssertTrue(state.status == JCSFlipGameStatusPlayerAWon || state.status == JCSFlipGameStatusPlayerBWon || state.status == JCSFlipGameStatusDraw, nil);
}

@end
