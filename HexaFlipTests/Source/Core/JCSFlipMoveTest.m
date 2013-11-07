//
//  JCSFlipMoveTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSFlipMoveInputDelegate.h"

#import "OCMock.h"

@interface JCSFlipMoveTest : SenTestCase
@end

@implementation JCSFlipMoveTest {
    volatile BOOL _moveInputDone;
}

- (void)setUp {
    _moveInputDone = NO;
}

- (void)testInitMove {
    JCSFlipMove *move = [[JCSFlipMove alloc] initWithStartRow:1 startColumn:4 direction:JCSHexDirectionNE];
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 1, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionNE, nil);
}

- (void)testInitSkip {
    JCSFlipMove *move = [[JCSFlipMove alloc] initSkip];
    
    STAssertTrue(move.skip, nil);
    STAssertThrows([move startRow], nil);
    STAssertThrows([move startColumn], nil);
    STAssertThrows([move direction], nil);
}

- (void)testMove {
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 3, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionSE, nil);
}

- (void)testSkip {
    JCSFlipMove *move = [JCSFlipMove moveSkip];
    
    STAssertTrue(move.skip, nil);
    STAssertThrows([move startRow], nil);
    STAssertThrows([move startColumn], nil);
    STAssertThrows([move direction], nil);
}

- (void)testMutable {
    JCSFlipMove *move = [JCSFlipMove moveSkip];
    
    move.skip = NO;
    move.startRow = 1;
    move.startColumn = 2;
    move.direction = JCSHexDirectionNW;
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 1, nil);
    STAssertEquals(move.startColumn, 2, nil);
    STAssertEquals(move.direction, JCSHexDirectionNW, nil);
}

- (void)testCopy {
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:32 startColumn:12 direction:JCSHexDirectionE];
    JCSFlipMove *copy = [move copy];
    
    STAssertFalse(move == copy, nil);
    STAssertTrue([copy class] == [JCSFlipMove class], nil);
    STAssertEquals(move.skip, copy.skip, nil);
    STAssertEquals(move.startRow, copy.startRow, nil);
    STAssertEquals(move.startColumn, copy.startColumn, nil);
    STAssertEquals(move.direction, copy.direction, nil);
}

- (void)runMainLoopUntilMoveInputDone {
    NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
    for (int i = 0; i < 50 && !_moveInputDone; i++) {
        NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [mainRunLoop runUntilDate:timeout];
    }
}

- (void)triggerMoveInputDone {
    _moveInputDone = YES;
}

- (void)doTestPerformInputWhenNormalMoveValid:(BOOL)valid {
    NSInteger startRow = 17;
    NSInteger startColumn = 23;
    JCSHexDirection direction = JCSHexDirectionNW;
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:startRow startColumn:startColumn direction:direction];
    // use nice mock to avoid errors caused by unexpected invocations of this mock when running the main run loop in another test method
    OCMockObject<JCSFlipMoveInputDelegate> *delegateMock = [OCMockObject niceMockForProtocol:@protocol(JCSFlipMoveInputDelegate)];
    [delegateMock setExpectationOrderMatters:YES];
    [[[delegateMock expect] andReturnValue:@(valid)] inputSelectedStartRow:startRow startColumn:startColumn];
    [[delegateMock expect] inputSelectedDirection:direction startRow:startRow startColumn:startColumn];
    [[delegateMock expect] inputClearedDirection:direction startRow:startRow startColumn:startColumn];
    [[delegateMock expect] inputClearedStartRow:startRow startColumn:startColumn];
    [[[delegateMock expect] andCall:@selector(triggerMoveInputDone) onObject:self] inputConfirmedWithMove:move];
    
    [move performInputWithMoveInputDelegate:delegateMock];
    
    [self runMainLoopUntilMoveInputDone];
    [delegateMock verify];
}

- (void)testPerformInputWhenValidNormalMove {
    [self doTestPerformInputWhenNormalMoveValid:YES];
}

- (void)testPerformInputWhenInvalidStartPoint {
    [self doTestPerformInputWhenNormalMoveValid:NO];
}

- (void)testPerformInputWhenSkipMove {
    JCSFlipMove *move = [JCSFlipMove moveSkip];
    // use nice mock to avoid errors caused by unexpected invocations of this mock when running the main run loop in another test method
    OCMockObject<JCSFlipMoveInputDelegate> *delegateMock = [OCMockObject niceMockForProtocol:@protocol(JCSFlipMoveInputDelegate)];
    [[[delegateMock expect] andCall:@selector(triggerMoveInputDone) onObject:self] inputConfirmedWithMove:move];
    
    [move performInputWithMoveInputDelegate:delegateMock];
    
    [self runMainLoopUntilMoveInputDone];
    [delegateMock verify];
}

@end
