//
//  JCSHexCoordinateTest.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexCoordinate.h"

@interface JCSHexCoordinateTest : SenTestCase
@end

@implementation JCSHexCoordinateTest

- (void)testInitWithRowAndColumn {
    JCSHexCoordinate *underTest;

    underTest = [[JCSHexCoordinate alloc] initWithRow:123 column:-281];
    STAssertEquals(underTest.row, 123, nil);
    STAssertEquals(underTest.column, -281, nil);
    
    underTest = [[JCSHexCoordinate alloc] initWithRow:-701 column:312];
    STAssertEquals(underTest.row, -701, nil);
    STAssertEquals(underTest.column, 312, nil);
    
}

- (void)testInitWithHexCoordinateAndDirection {
    JCSHexCoordinate *original = [[JCSHexCoordinate alloc] initWithRow:-701 column:312];

    JCSHexCoordinate *underTest;
    
    underTest = [[JCSHexCoordinate alloc] initWithHexCoordinate:original direction:JCSHexDirectionE];
    STAssertEquals(underTest.row, -701, nil);
    STAssertEquals(underTest.column, 313, nil);

    underTest = [[JCSHexCoordinate alloc] initWithHexCoordinate:original direction:JCSHexDirectionNE];
    STAssertEquals(underTest.row, -700, nil);
    STAssertEquals(underTest.column, 312, nil);

    underTest = [[JCSHexCoordinate alloc] initWithHexCoordinate:original direction:JCSHexDirectionNW];
    STAssertEquals(underTest.row, -700, nil);
    STAssertEquals(underTest.column, 311, nil);

    underTest = [[JCSHexCoordinate alloc] initWithHexCoordinate:original direction:JCSHexDirectionW];
    STAssertEquals(underTest.row, -701, nil);
    STAssertEquals(underTest.column, 311, nil);

    underTest = [[JCSHexCoordinate alloc] initWithHexCoordinate:original direction:JCSHexDirectionSW];
    STAssertEquals(underTest.row, -702, nil);
    STAssertEquals(underTest.column, 312, nil);

    underTest = [[JCSHexCoordinate alloc] initWithHexCoordinate:original direction:JCSHexDirectionSE];
    STAssertEquals(underTest.row, -702, nil);
    STAssertEquals(underTest.column, 313, nil);
}

- (void)testReuse {
    JCSHexCoordinate *original1 = [[JCSHexCoordinate alloc] initWithRow:-701 column:312];
    JCSHexCoordinate *original2 = [[JCSHexCoordinate alloc] initWithRow:-699 column:311];
    
    JCSHexCoordinate *mod1 = [JCSHexCoordinate hexCoordinateWithHexCoordinate:original1 direction:JCSHexDirectionNE];
    JCSHexCoordinate *mod2 = [JCSHexCoordinate hexCoordinateWithRow:-700 column:312];
    JCSHexCoordinate *mod3 = [JCSHexCoordinate hexCoordinateWithHexCoordinate:original2 direction:JCSHexDirectionSE];
    JCSHexCoordinate *mod4 = [JCSHexCoordinate hexCoordinateWithRow:-700 column:312];
    
    STAssertNotNil(mod1, nil);
    STAssertEquals(mod1, mod2, nil);
    STAssertEquals(mod1, mod3, nil);
    STAssertEquals(mod1, mod4, nil);
    
    STAssertEquals(mod1.row, -700, nil);
    STAssertEquals(mod1.column, 312, nil);
}

- (void)testOrigin {
    JCSHexCoordinate *origin = [JCSHexCoordinate hexCoordinateForOrigin];
    
    STAssertEquals(origin.row, 0, nil);
    STAssertEquals(origin.column, 0, nil);
}

- (void)testDistance {
    NSInteger r0 = 392;
    NSInteger c0 = -293;
    
    JCSHexCoordinate *original = [[JCSHexCoordinate alloc] initWithRow:r0 column:c0];

    // on E
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0 column:c0+319]], 319, nil);

    // between E and NE
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0+423 column:c0+319]], 423+319, nil);

    // on NE
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0+423 column:c0]], 423, nil);

    // between NE and NW
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0+423 column:c0-215]], 423, nil);

    // on NW
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0+423 column:c0-423]], 423, nil);

    // between NW and W
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0+423 column:c0-513]], 513, nil);

    // on W
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0 column:c0-319]], 319, nil);

    // between W and SW
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0-423 column:c0-319]], 423+319, nil);

    // on SW
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0-423 column:c0]], 423, nil);

    // between SW and SE
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0-423 column:c0+215]], 423, nil);

    // on SE
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0-423 column:c0+423]], 423, nil);

    // between SE and E
    STAssertEquals([original distanceTo:[JCSHexCoordinate hexCoordinateWithRow:r0-423 column:c0+513]], 513, nil);
}

- (void)testCopyIsSelf {
    JCSHexCoordinate *original = [[JCSHexCoordinate alloc] initWithRow:391 column:-582];
    JCSHexCoordinate *copy = [original copy];

    STAssertEquals(original, copy, nil);
}

@end
