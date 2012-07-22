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

- (void)testInit {
    JCSFlipMove *move = [[JCSFlipMove alloc] initWithStartRow:1 startColumn:4 direction:JCSHexDirectionNE];
    
    STAssertEquals(move.startRow, 1, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionNE, nil);
}

- (void)testReuse {
    JCSFlipMove *move1 = [JCSFlipMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    JCSFlipMove *move2 = [JCSFlipMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    
    STAssertNotNil(move1, nil);
    STAssertEquals(move1, move2, nil);
    
    STAssertEquals(move1.startRow, 3, nil);
    STAssertEquals(move1.startColumn, 4, nil);
    STAssertEquals(move1.direction, JCSHexDirectionSE, nil);
}

@end
