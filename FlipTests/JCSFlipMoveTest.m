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
    // TODO: use OCMock to mock the coordinate
    JCSHexCoordinate *start = [JCSHexCoordinate hexCoordinateWithRow:0 column:0];
    JCSFlipMove *move = [[JCSFlipMove alloc] initWithStart:start direction:JCSHexDirectionNE];
    
    STAssertEquals(move.start, start, nil);
    STAssertEquals(move.direction, JCSHexDirectionNE, nil);
}

- (void)testReuse {
    // TODO: use OCMock to mock the coordinate
    JCSHexCoordinate *start1 = [[JCSHexCoordinate alloc] initWithRow:3 column:-4];
    JCSHexCoordinate *start2 = [[JCSHexCoordinate alloc] initWithRow:3 column:-4];

    JCSFlipMove *move1 = [JCSFlipMove moveWithStart:start1 direction:JCSHexDirectionSE];
    JCSFlipMove *move2 = [JCSFlipMove moveWithStart:start2 direction:JCSHexDirectionSE];
    
    STAssertNotNil(move1, nil);
    STAssertEquals(move1, move2, nil);
    
    STAssertEquals(move1.start, start1, nil);
    STAssertEquals(move1.direction, move1.direction, nil);
}

@end
