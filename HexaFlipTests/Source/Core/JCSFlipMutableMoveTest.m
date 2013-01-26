//
//  JCSFlipMutableMoveTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 28.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMutableMove.h"

@interface JCSFlipMutableMoveTest : SenTestCase
@end

@implementation JCSFlipMutableMoveTest

- (void)testInitMove {
    JCSFlipMutableMove *move = [[JCSFlipMutableMove alloc] initWithStartRow:1 startColumn:4 direction:JCSHexDirectionNE];
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 1, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionNE, nil);
}

- (void)testInitSkip {
    JCSFlipMutableMove *move = [[JCSFlipMutableMove alloc] initSkip];
    
    STAssertTrue(move.skip, nil);
    STAssertThrows([move startRow], nil);
    STAssertThrows([move startColumn], nil);
    STAssertThrows([move direction], nil);
}

- (void)testMove {
    JCSFlipMutableMove *move = [JCSFlipMutableMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 3, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionSE, nil);
}

- (void)testSkip {
    JCSFlipMutableMove *move = [JCSFlipMutableMove moveSkip];
    
    STAssertTrue(move.skip, nil);
    STAssertThrows([move startRow], nil);
    STAssertThrows([move startColumn], nil);
    STAssertThrows([move direction], nil);
}

- (void)testMutable {
    JCSFlipMutableMove *move = [JCSFlipMutableMove moveSkip];
    
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

- (void)testMutableCopy {
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:17 startColumn:31 direction:JCSHexDirectionE];
    JCSFlipMove *copy = [move mutableCopy];

    STAssertFalse(move == copy, nil);
    STAssertTrue([copy class] == [JCSFlipMutableMove class], nil);
    STAssertEquals(move.skip, copy.skip, nil);
    STAssertEquals(move.startRow, copy.startRow, nil);
    STAssertEquals(move.startColumn, copy.startColumn, nil);
    STAssertEquals(move.direction, copy.direction, nil);
}

@end
