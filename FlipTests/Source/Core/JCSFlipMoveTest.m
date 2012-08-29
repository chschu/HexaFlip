//
//  JCSFlipMoveTest.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSFlipMutableMove.h"

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

- (void)testImmutable {
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:1 startColumn:2 direction:JCSHexDirectionE];
    
    STAssertFalse([move respondsToSelector:@selector(setSkip:)], nil);
    STAssertFalse([move respondsToSelector:@selector(setStartRow:)], nil);
    STAssertFalse([move respondsToSelector:@selector(setStartColumn:)], nil);
    STAssertFalse([move respondsToSelector:@selector(setDirection:)], nil);
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
