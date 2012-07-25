//
//  JCSFlipMoveTest.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"

@interface JCSFlipMoveTest : SenTestCase
@end

@implementation JCSFlipMoveTest

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

- (void)testReuseMove {
    JCSFlipMove *move1 = [JCSFlipMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    JCSFlipMove *move2 = [JCSFlipMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    
    STAssertNotNil(move1, nil);
    STAssertEquals(move1, move2, nil);
    
    STAssertFalse(move1.skip, nil);
    STAssertEquals(move1.startRow, 3, nil);
    STAssertEquals(move1.startColumn, 4, nil);
    STAssertEquals(move1.direction, JCSHexDirectionSE, nil);
}

- (void)testReuseSkip {
    JCSFlipMove *move1 = [JCSFlipMove moveSkip];
    JCSFlipMove *move2 = [JCSFlipMove moveSkip];
    
    STAssertNotNil(move1, nil);
    STAssertEquals(move1, move2, nil);
    
    STAssertTrue(move1.skip, nil);
    STAssertThrows([move1 startRow], nil);
    STAssertThrows([move1 startColumn], nil);
    STAssertThrows([move1 direction], nil);
}

@end
