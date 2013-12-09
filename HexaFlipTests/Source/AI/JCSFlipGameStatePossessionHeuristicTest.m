//
//  JCSFlipGameStatePossessionHeuristicTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 06.11.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatePossessionHeuristic.h"
#import "JCSFlipGameState.h"

#import "OCMock.h"

@interface JCSFlipGameStatePossessionHeuristicTest : SenTestCase
@end

@implementation JCSFlipGameStatePossessionHeuristicTest {
    JCSFlipGameStatePossessionHeuristic *_underTest;
}

- (void)setUp {
    _underTest = [[JCSFlipGameStatePossessionHeuristic alloc] init];
}

- (void)testValueIsDifferenceWhenPlayerAToMove {
    id gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipGameStatusOpen)] status];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipPlayerSideA)] playerToMove];
    [[[gameStateMock stub] andReturnValue:@13] cellCountPlayerA];
    [[[gameStateMock stub] andReturnValue:@17] cellCountPlayerB];
    
    STAssertEquals(-4.0f, [_underTest valueOfNode:gameStateMock], @"heuristic value must be difference of cell counts");
}

- (void)testValueIsNegativeDifferenceWhenPlayerBToMove {
    id gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipGameStatusOpen)] status];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipPlayerSideB)] playerToMove];
    [[[gameStateMock stub] andReturnValue:@4] cellCountPlayerA];
    [[[gameStateMock stub] andReturnValue:@12] cellCountPlayerB];
    
    STAssertEquals(8.0f, [_underTest valueOfNode:gameStateMock], @"heuristic value must be negative difference of cell counts");
}

- (void)testValueIsNegativeHugeWhenCurrentPlayerLost {
    id gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipGameStatusPlayerBWon)] status];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipPlayerSideA)] playerToMove];
    [[[gameStateMock stub] andReturnValue:@4] cellCountPlayerA];
    [[[gameStateMock stub] andReturnValue:@10] cellCountPlayerB];
    
    STAssertTrue([_underTest valueOfNode:gameStateMock] < -1e6, @"heuristic value must be negative huge");
}

- (void)testValueIsNegativeInfinityWhenCurrentPlayerWithoutCells {
    id gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipGameStatusPlayerAWon)] status];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipPlayerSideB)] playerToMove];
    [[[gameStateMock stub] andReturnValue:@4] cellCountPlayerA];
    [[[gameStateMock stub] andReturnValue:@0] cellCountPlayerB];
    
    STAssertEquals(-INFINITY, [_underTest valueOfNode:gameStateMock], @"heuristic value must be negative infinity");
}

- (void)testValueIsPositiveHugeWhenOtherPlayerLost {
    id gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipGameStatusPlayerAWon)] status];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipPlayerSideA)] playerToMove];
    [[[gameStateMock stub] andReturnValue:@13] cellCountPlayerA];
    [[[gameStateMock stub] andReturnValue:@1] cellCountPlayerB];
    
    STAssertTrue([_underTest valueOfNode:gameStateMock] > 1e6, @"heuristic value must be positive huge");
}

- (void)testValueIsPositiveInfinityWhenOtherPlayerWithoutCells {
    id gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipGameStatusPlayerBWon)] status];
    [[[gameStateMock stub] andReturnValue:@(JCSFlipPlayerSideB)] playerToMove];
    [[[gameStateMock stub] andReturnValue:@0] cellCountPlayerA];
    [[[gameStateMock stub] andReturnValue:@10] cellCountPlayerB];
    
    STAssertEquals(INFINITY, [_underTest valueOfNode:gameStateMock], @"heuristic value must be positive infinity");
}

- (void)testHugeValueOnGameOverConsidersCellDifference {
    id gameStateMock1 = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock1 stub] andReturnValue:@(JCSFlipGameStatusPlayerAWon)] status];
    [[[gameStateMock1 stub] andReturnValue:@(JCSFlipPlayerSideA)] playerToMove];
    [[[gameStateMock1 stub] andReturnValue:@10] cellCountPlayerA];
    [[[gameStateMock1 stub] andReturnValue:@7] cellCountPlayerB];
    id gameStateMock2 = [OCMockObject mockForClass:[JCSFlipGameState class]];
    [[[gameStateMock2 stub] andReturnValue:@(JCSFlipGameStatusPlayerAWon)] status];
    [[[gameStateMock2 stub] andReturnValue:@(JCSFlipPlayerSideA)] playerToMove];
    [[[gameStateMock2 stub] andReturnValue:@10] cellCountPlayerA];
    [[[gameStateMock2 stub] andReturnValue:@8] cellCountPlayerB];

    STAssertTrue([_underTest valueOfNode:gameStateMock1] > [_underTest valueOfNode:gameStateMock2], @"heuristic value must be larger for larger cell difference");
}

@end
