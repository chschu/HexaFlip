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
    JCSHexCoordinate *start = [JCSHexCoordinate hexCoordinateWithRow:3 column:-4];

    JCSFlipMove *move1 = [JCSFlipMove moveWithStart:start direction:JCSHexDirectionSE];
    JCSFlipMove *move2 = [JCSFlipMove moveWithStart:start direction:JCSHexDirectionSE];
    
    STAssertNotNil(move1, nil);
    STAssertEquals(move1, move2, nil);
    
    STAssertEquals(move1.start, start, nil);
    STAssertEquals(move1.direction, JCSHexDirectionSE, nil);
}

@end
