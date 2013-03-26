//
//  JCSFlipAlgoTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 20.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSNegamaxGameAlgorithm.h"
#import "JCSRandomGameAlgorithm.h"
#import "JCSFlipCellState.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameStatePSRHeuristic.h"

@interface JCSFlipAlgoTest : SenTestCase
@end

@implementation JCSFlipAlgoTest

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) ({ \
__typeof__(r1) _r1 = (r1); \
__typeof__(c1) _c1 = (c1); \
__typeof__(r2) _r2 = (r2); \
__typeof__(c2) _c2 = (c2); \
MAX(MAX(abs(_r1-_r2), abs(_c1-_c2)), abs((_r1+_c1)-(_r2+_c2))); \
})

- (void)testNegamax2VsNegamax1 {
    id<JCSGameHeuristic> paranoid = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:3 randomness:0];
    id<JCSGameAlgorithm> algoA = [[JCSNegamaxGameAlgorithm alloc] initWithDepth:2 heuristic:paranoid];
    id<JCSGameAlgorithm> algoB = [[JCSNegamaxGameAlgorithm alloc] initWithDepth:1 heuristic:paranoid];
    NSInteger size = 4;
    [self testAlgorithm:algoA againstAlgorithm:algoB withBoardSize:size];
}


- (void)testNegamax3VsNegamax2 {
    id<JCSGameHeuristic> careless = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0 randomness:2];
    id<JCSGameHeuristic> paranoid = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:3 randomness:0];
    id<JCSGameAlgorithm> algoA = [[JCSNegamaxGameAlgorithm alloc] initWithDepth:3 heuristic:careless];
    id<JCSGameAlgorithm> algoB = [[JCSNegamaxGameAlgorithm alloc] initWithDepth:2 heuristic:paranoid];
    NSInteger size = 4;
    [self testAlgorithm:algoA againstAlgorithm:algoB withBoardSize:size];
}

- (void)testNegamax3VsRandom {
    id<JCSGameHeuristic> safe = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0.5 randomness:0.25];
    id<JCSGameAlgorithm> algoA = [[JCSNegamaxGameAlgorithm alloc] initWithDepth:3 heuristic:safe];
    id<JCSGameAlgorithm> algoB = [[JCSRandomGameAlgorithm alloc] initWithSeed:9391829];
    NSInteger size = 4;
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
    
    JCSFlipGameState *state = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerToMoveA cellStateAtBlock:cellStateAtBlock];
    
    while (true) {
        id<JCSGameAlgorithm> algo = (state.playerToMove == JCSFlipPlayerToMoveA ? algoA : algoB);
        
        JCSFlipMove *move = [algo moveAtNode:state];
        if (move == nil) {
            break;
        }
        
        [state pushMove:move];
        
        NSLog(@"\n%@", state);
    }
    NSLog(@"done, final scores %d:%d", state.cellCountPlayerA, state.cellCountPlayerB);
    
    STAssertTrue(state.status == JCSFlipGameStatusPlayerAWon || state.status == JCSFlipGameStatusPlayerBWon || state.status == JCSFlipGameStatusDraw, nil);
}

@end
