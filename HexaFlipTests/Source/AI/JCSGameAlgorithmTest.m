//
//  JCSFlipAlgoTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 20.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSNegamaxGameAlgorithm.h"
#import "JCSNegaScoutGameAlgorithm.h"
#import "JCSRandomGameAlgorithm.h"
#import "JCSFlipCellState.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameStatePSRHeuristic.h"
#import "JCSFlipGameStatePossessionHeuristic.h"

@interface JCSFlipAlgoTest : XCTestCase
@end

@implementation JCSFlipAlgoTest

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

- (void)testNegaScoutVsNegaScout {
    id<JCSGameHeuristic> possessive = [[JCSFlipGameStatePossessionHeuristic alloc] init];
    id<JCSGameAlgorithm> algoA = [[JCSNegaScoutGameAlgorithm alloc] initWithDepth:4 heuristic:possessive];
    id<JCSGameAlgorithm> algoB = [[JCSNegaScoutGameAlgorithm alloc] initWithDepth:4 heuristic:possessive];
    NSInteger size = 4;
    [self testAlgorithm:algoA againstAlgorithm:algoB withBoardSize:size];
}

- (void)testAlgorithm:(id<JCSGameAlgorithm>)algoA againstAlgorithm:(id<JCSGameAlgorithm>)algoB withBoardSize:(NSInteger)size {
    JCSFlipGameState *state = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA];
    
    while (!state.leaf) {
        id<JCSGameAlgorithm> algo = (state.playerToMove == JCSFlipPlayerSideA ? algoA : algoB);
        id<JCSMove> move = [algo moveAtNode:state];
        XCTAssertNotNil(move, @"move returned by algorithm must not be nil for non-leaf node");
        [state pushMove:move];
        NSLog(@"\n%@", state);
    }
    NSLog(@"done, final scores %d:%d", state.cellCountPlayerA, state.cellCountPlayerB);
    
    XCTAssertTrue(state.status == JCSFlipGameStatusPlayerAWon || state.status == JCSFlipGameStatusPlayerBWon || state.status == JCSFlipGameStatusDraw);
}

@end
