//
//  JCSCellTest.m
//  Flip
//
//  Created by Christian Schuster on 16.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSCellTest.h"
#import "JCSCell.h"

@implementation JCSCellTest {
    JCSCell *underTest;
}

- (void)setUp {
    underTest = [[JCSCell alloc] init];
}

- (void)testInitialOwner {
    STAssertNil(underTest.owner, @"initial owner must be nil");
}

- (void)testOccupyA {
    [underTest occupyWithPlayer:[JCSPlayer A]];
    STAssertEquals(underTest.owner, [JCSPlayer A], @"owner must be A");
}

- (void)testOccupyB {
    [underTest occupyWithPlayer:[JCSPlayer B]];
    STAssertEquals(underTest.owner, [JCSPlayer B], @"owner must be B");
}

- (void)testOccupyNil {
    @try {
        [underTest occupyWithPlayer:nil];
        STFail(@"expected exception not thrown");
    }
    @catch (NSException *e) {
        STAssertNil(underTest.owner, @"owner must not change");
    }
}

- (void)testOccupyAlreadyOccupied {
    [underTest occupyWithPlayer:[JCSPlayer A]];
    @try {
        [underTest occupyWithPlayer:[JCSPlayer A]];
        STFail(@"expected exception not thrown");
    }
    @catch (NSException *e) {
        STAssertEquals(underTest.owner, [JCSPlayer A], @"owner must not change");
    }
}

@end
