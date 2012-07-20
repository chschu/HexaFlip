//
//  JCSFlipGameStateTest.m
//  Flip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSPlayer.h"
#import "JCSFlipCellState.h"
#import "JCSHexCoordinate.h"

@interface JCSFlipGameStateTest : SenTestCase
@end

@implementation JCSFlipGameStateTest

- (void)testInitSizeNegative {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return NO;
	};
	
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
		return JCSFlipCellStateEmpty; 
	};

    JCSFlipGameState *underTest;
    STAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:-1 playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock], nil);
}

- (void)testInitCellAtBlockNil {
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
		return JCSFlipCellStateEmpty; 
	};
    
	JCSFlipGameState *underTest;
    STAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:10 playerToMove:JCSPlayerA cellAtBlock:nil cellStateAtBlock:cellStateAtBlock], nil);
}

- (void)testInitCellStateAtBlockNil {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return NO;
	};

	JCSFlipGameState *underTest;
    STAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:10 playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:nil], nil);
}

- (void)testInitSetsPlayerToMove {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return NO;
	};
	
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
		return JCSFlipCellStateEmpty; 
	};

	JCSFlipGameState *underTest;

    underTest = [[JCSFlipGameState alloc] initWithSize:1 playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];
    STAssertEquals(underTest.playerToMove, JCSPlayerA, nil);

    underTest = [[JCSFlipGameState alloc] initWithSize:1 playerToMove:JCSPlayerB cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];
    STAssertEquals(underTest.playerToMove, JCSPlayerB, nil);
}
    
- (void)testInitInvokesCellAtBlock {
	// coordinates for which cellAtBlock has been called 
	NSMutableSet *cellAtBlockCalledFor = [NSMutableSet set];
    
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
        STAssertFalse([cellAtBlockCalledFor containsObject:coordinate], nil);
		[cellAtBlockCalledFor addObject:coordinate];
		return NO;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
		// dummy implementation, block should never be called
		STFail(@"unexpected invocation");
		return JCSFlipCellStateEmpty; 
	};
    
	NSInteger size = 15;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];
#pragma unused(underTest)
    
	// check number of invocations with unique coordinates
	STAssertEquals([cellAtBlockCalledFor count], (NSUInteger) ((2*size-1)*(2*size-1)), nil);
}

- (void)testInitInvokesCellStateAtBlock {
	// coordinates for which cellAtBlock returned true 
	NSMutableSet *cellAtBlockReturnedTrueFor = [NSMutableSet set];
	
	// coordinates for which cellStateAtBlock has been called
	NSMutableSet *cellStateAtBlockCalledFor = [NSMutableSet set];
    
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		if ((coordinate.row * coordinate.column) % 2 == 0) {
            STAssertFalse([cellAtBlockReturnedTrueFor containsObject:coordinate], nil);
			[cellAtBlockReturnedTrueFor addObject:coordinate];
			return YES;
		}
		return NO;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
        STAssertFalse([cellStateAtBlockCalledFor containsObject:coordinate], nil);
		[cellStateAtBlockCalledFor addObject:coordinate];
		return JCSFlipCellStateEmpty; 
	};
    
	NSInteger size = 14;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];
#pragma unused(underTest)
    
	// check that cellStateAtBlock is called for every coordinate for which cellAtBlock returned true 
	STAssertTrue([cellAtBlockReturnedTrueFor isEqualToSet:cellStateAtBlockCalledFor], nil);
}

- (void)testInitStoresCells {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return abs(coordinate.row * coordinate.column) % 4 == 0;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
        NSInteger rem = abs(coordinate.row * coordinate.column) % 3;
        if (rem == 1) {
			return JCSFlipCellStateOwnedByPlayerA;
		} else if (rem == 2) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	NSInteger size = 10;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];

    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            JCSHexCoordinate *coord = [JCSHexCoordinate hexCoordinateWithRow:row column:column];
            NSInteger r3 = abs(row * column) % 3;
            NSInteger r4 = abs(row * column) % 4;
            
            // check cell (verifies that hasCellAt behaves as expected)
            STAssertEquals([underTest hasCellAt:coord], (BOOL) (r4 == 0), nil);

            // check cell state (verifies that cellStateAt behaves as expected)
            if (r4 == 0) {
                if (r3 == 1) {
                    STAssertEquals([underTest cellStateAt:coord], JCSFlipCellStateOwnedByPlayerA, nil);
                } else if (r3 == 2) {
                    STAssertEquals([underTest cellStateAt:coord], JCSFlipCellStateOwnedByPlayerB, nil);
                } else {
                    STAssertEquals([underTest cellStateAt:coord], JCSFlipCellStateEmpty, nil);
                }
            }
        }
    }
}

- (void)testCellStateFailsForNonExistingCell {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return NO;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
		// dummy implementation, block should never be called
		STFail(@"unexpected invocation");
		return JCSFlipCellStateEmpty; 
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:1 playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];
    STAssertThrows([underTest cellStateAt:[JCSHexCoordinate hexCoordinateWithRow:0 column:0]], nil);
}

- (void)testCopyIndependent {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return YES;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
        if (coordinate.row == 0 && coordinate.column == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (coordinate.row == -1 && coordinate.column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
    };
    
	JCSFlipGameState *original = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];

    // create a copy, and apply a move to it
    JCSFlipGameState *copy = [original copy];
    [copy applyMove:[JCSFlipMove moveWithStart:[JCSHexCoordinate hexCoordinateForOrigin] direction:JCSHexDirectionNE]];

    // check that the original is unchanged
    STAssertEquals(original.playerToMove, JCSPlayerA, nil);
    STAssertEquals([original cellStateAt:[JCSHexCoordinate hexCoordinateWithRow:1 column:0]], JCSFlipCellStateEmpty, nil);
}

- (void)testInvokeForAllCells {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return YES;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
        if (coordinate.row == 0 && coordinate.column == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (coordinate.row == -1 && coordinate.column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        }
		return JCSFlipCellStateEmpty; 
	};
    
    NSInteger size = 3;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];

    NSMutableSet *visitorBlockCalledFor = [NSMutableSet set];
    
    void(^visitorBlock)(JCSHexCoordinate *, JCSFlipCellState, BOOL *) = ^(JCSHexCoordinate *coordinate, JCSFlipCellState cellState, BOOL *stop) {
        STAssertFalse([visitorBlockCalledFor containsObject:coordinate], nil);
        [visitorBlockCalledFor addObject:coordinate];

        // check for correct state
        if (coordinate.row == 0 && coordinate.column == 0) {
            STAssertEquals(cellState, JCSFlipCellStateOwnedByPlayerA, nil);
        } else if (coordinate.row == -1 && coordinate.column == 0) {
            STAssertEquals(cellState, JCSFlipCellStateOwnedByPlayerB, nil);
        } else {
            STAssertEquals(cellState, JCSFlipCellStateEmpty, nil);
        }
    };
    
    [underTest forAllCellsInvokeBlock:visitorBlock];

	STAssertEquals([visitorBlockCalledFor count], (NSUInteger) ((2*size-1)*(2*size-1)), nil);
}

- (void)testInvokeForAllCellsStops {
	BOOL(^cellAtBlock)(JCSHexCoordinate *) = ^BOOL(JCSHexCoordinate *coordinate) {
		return YES;
	};
    
	JCSFlipCellState(^cellStateAtBlock)(JCSHexCoordinate *) = ^JCSFlipCellState(JCSHexCoordinate *coordinate) {
		return JCSFlipCellStateEmpty; 
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:10 playerToMove:JCSPlayerA cellAtBlock:cellAtBlock cellStateAtBlock:cellStateAtBlock];

    __block NSInteger visitorBlockCalledCount = 0;
    
    void(^visitorBlock)(JCSHexCoordinate *, JCSFlipCellState, BOOL *) = ^(JCSHexCoordinate *coordinate, JCSFlipCellState cellState, BOOL *stop) {
        ++visitorBlockCalledCount;
        // fail if called more than 14 times
        STAssertTrue(visitorBlockCalledCount <= 14, nil);
        // set *stop if called exactly 14 times 
        if (visitorBlockCalledCount == 14) {
            *stop = YES;
        }
    };
    
    [underTest forAllCellsInvokeBlock:visitorBlock];
}

@end
