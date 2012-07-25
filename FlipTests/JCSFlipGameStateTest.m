//
//  JCSFlipGameStateTest.m
//  Flip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipGameStatus.h"
#import "JCSFlipCellState.h"

@interface JCSFlipGameStateTest : SenTestCase
@end

@implementation JCSFlipGameStateTest

- (void)testInitSizeNegative {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
		return JCSFlipCellStateEmpty; 
	};

    JCSFlipGameState *underTest;
    STAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:-1 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock], nil);
}

- (void)testInitCellStateAtBlockNil {
	JCSFlipGameState *underTest;
    STAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:10 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:nil], nil);
}

- (void)testInitSetsStateNormal {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};

	JCSFlipGameState *underTest;

    underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAToMove, nil);

    underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerBToMove cellStateAtBlock:cellStateAtBlock];
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);
}

- (void)testInitSetsStateGameOver {
	JCSFlipCellState(^cellStateAtBlockA)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};

    JCSFlipCellState(^cellStateAtBlockB)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};

    JCSFlipCellState(^cellStateAtBlockDraw)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0 && column != 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row != 0 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateHole;
        }
	};

	JCSFlipGameState *underTest;
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlockA];
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAWon, nil);
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerBToMove cellStateAtBlock:cellStateAtBlockB];
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBWon, nil);

    underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlockDraw];
    STAssertEquals(underTest.status, JCSFlipGameStatusDraw, nil);
}

- (void)testInitInvokesCellStateAtBlock {
	// coordinates for which cellStateAtBlock has been called
	NSMutableSet *cellStateAtBlockCalledFor = [NSMutableSet set];
    
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        NSNumber *coordinate = [NSNumber numberWithInt:1000*row+column];
        STAssertFalse([cellStateAtBlockCalledFor containsObject:coordinate], nil);
		[cellStateAtBlockCalledFor addObject:coordinate];
		return JCSFlipCellStateEmpty; 
	};
    
	NSInteger size = 14;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
#pragma unused(underTest)
    
	// check that cellStateAtBlock is called for every coordinate
	STAssertEquals([cellStateAtBlockCalledFor count], (NSUInteger) ((2*size-1)*(2*size-1)), nil);
}

- (void)testInitStoresCells {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (abs(row * column) % 4 == 0) {
            return JCSFlipCellStateHole;
        } else {
            NSInteger rem = abs(row * column) % 3;
            if (rem == 1) {
                return JCSFlipCellStateOwnedByPlayerA;
            } else if (rem == 2) {
                return JCSFlipCellStateOwnedByPlayerB;
            } else {
                return JCSFlipCellStateEmpty;
            }
        }
	};
    
	NSInteger size = 10;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];

    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            NSInteger r3 = abs(row * column) % 3;
            NSInteger r4 = abs(row * column) % 4;

            // check cell state (verifies that cellStateAt behaves as expected)
            if (r4 == 0) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateHole, nil);
            } else if (r3 == 1) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateOwnedByPlayerA, nil);
            } else if (r3 == 2) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateOwnedByPlayerB, nil);
            } else {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateEmpty, nil);
            }
        }
    }
}

- (void)testCellStateOutsideRange {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
		return JCSFlipCellStateEmpty; 
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:3 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    STAssertEquals([underTest cellStateAtRow:-3 column:0], JCSFlipCellStateHole, nil);
    STAssertEquals([underTest cellStateAtRow:3 column:0], JCSFlipCellStateHole, nil);
    STAssertEquals([underTest cellStateAtRow:0 column:-3], JCSFlipCellStateHole, nil);
    STAssertEquals([underTest cellStateAtRow:0 column:3], JCSFlipCellStateHole, nil);
}

- (void)testCopyIndependent {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == -1 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
    };
    
	JCSFlipGameState *original = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];

    // create a copy, and apply a move to it
    JCSFlipGameState *copy = [original copy];
    [copy applyMove:[JCSFlipMove moveWithStartRow:0 startColumn:0 direction:JCSHexDirectionNE]];

    // check that the original is unchanged
    STAssertEquals(original.status, JCSFlipGameStatusPlayerAToMove, nil);
    STAssertEquals([original cellStateAtRow:1 column:0], JCSFlipCellStateEmpty, nil);
}

- (void)testInvokeForAllCells {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == -1 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        }
		return JCSFlipCellStateEmpty; 
	};
    
    NSInteger size = 3;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];

    NSMutableSet *visitorBlockCalledFor = [NSMutableSet set];
    
    void(^visitorBlock)(NSInteger, NSInteger, JCSFlipCellState, BOOL *) = ^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        NSNumber *coordinate = [NSNumber numberWithInt:1000*row+column];
        STAssertFalse([visitorBlockCalledFor containsObject:coordinate], nil);
        [visitorBlockCalledFor addObject:coordinate];

        // check for correct state
        if (row == 0 && column == 0) {
            STAssertEquals(cellState, JCSFlipCellStateOwnedByPlayerA, nil);
        } else if (row == -1 && column == 0) {
            STAssertEquals(cellState, JCSFlipCellStateOwnedByPlayerB, nil);
        } else {
            STAssertEquals(cellState, JCSFlipCellStateEmpty, nil);
        }
    };
    
    [underTest forAllCellsInvokeBlock:visitorBlock];

	STAssertEquals([visitorBlockCalledFor count], (NSUInteger) ((2*size-1)*(2*size-1)), nil);
}

- (void)testInvokeForAllCellsStops {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
		return JCSFlipCellStateEmpty; 
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:10 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];

    void(^visitorBlock)(NSInteger row, NSInteger column, JCSFlipCellState, BOOL *);
    __block NSInteger visitorBlockCalledCount;
    
    visitorBlockCalledCount = 0;
    visitorBlock = ^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        visitorBlockCalledCount++;
        // fail if called more than 14 times
        STAssertTrue(visitorBlockCalledCount <= 14, nil);
        // set *stop if called exactly 14 times 
        if (visitorBlockCalledCount == 14) {
            *stop = YES;
        }
    };
    [underTest forAllCellsInvokeBlock:visitorBlock];

    visitorBlockCalledCount = 0;
    visitorBlock = ^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        visitorBlockCalledCount++;
        // fail if called more than 9 times
        STAssertTrue(visitorBlockCalledCount <= 9, nil);
        // set *stop if called exactly 9 times 
        if (visitorBlockCalledCount == 9) {
            *stop = YES;
        }
    };
    [underTest forAllCellsInvokeBlock:visitorBlock];
}

- (void)testMoveOk {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (-1,0) and pointing NW
        if ((row == -1 && column == 0) || (row == 1 && column == -2)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
    NSInteger size = 4;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];

    // verify that move is valid
    STAssertTrue([underTest applyMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNW]], nil);
    
    // check that the player has been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);

    // check that cells states are modified correctly
    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            // A-A-B-A chain starting at (-1,0) and pointing NW
            if ((row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3)) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateOwnedByPlayerA, nil);
            } else if (row == 1 && column == -2) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateOwnedByPlayerB, nil);
            } else {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateEmpty, nil);
            }
        }
    }

    // verify that move is valid
    STAssertTrue([underTest applyMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionE]], nil);

    // check that the player has been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAToMove, nil);

    // check that cells states are modified correctly
    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            // A-A-B-A chain starting at (-1,0) and pointing NW, and B at (1,-1)
            if ((row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3)) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateOwnedByPlayerA, nil);
            } else if ((row == 1 && column == -1) || (row == 1 && column == -2)) {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateOwnedByPlayerB, nil);
            } else {
                STAssertEquals([underTest cellStateAtRow:row column:column], JCSFlipCellStateEmpty, nil);
            }
        }
    }
}

- (void)testMoveStartCellStateMismatch {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // hole at (-2,0), A-B-A chain starting at (-1,0) and pointing northeast
        if (row == -2 && column == 0) {
            return JCSFlipCellStateHole;
        } else if ((row == -1 && column == 0) || (row == 1 && column == 2)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == 1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
    JCSFlipGameState *underTest;
    
    // case 1: cell owned by B, player A to move
	underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:0 startColumn:1 direction:JCSHexDirectionNE]], nil);
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAToMove, nil);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];

    // case 2: cell empty, player A to move
    underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:1 startColumn:0 direction:JCSHexDirectionNE]], nil);
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAToMove, nil);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];

    // case 3: cell hole, player A to move
    underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:-2 startColumn:0 direction:JCSHexDirectionNE]], nil);
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAToMove, nil);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];

    // case 4: cell owned by A, player B to move
	underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerBToMove cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNE]], nil);
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];

    // case 5: cell empty, player B to move
	underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerBToMove cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:-2 startColumn:0 direction:JCSHexDirectionNE]], nil);
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];
    
    // case 6: cell hole, player A to move
    underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerBToMove cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:-2 startColumn:0 direction:JCSHexDirectionNE]], nil);
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];
}

- (void)testMoveGameOverAfterLastMove {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0 && column == 1) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == 0) {
            return JCSFlipCellStateEmpty;
        } else {
            return JCSFlipCellStateOwnedByPlayerB;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is invalid
    STAssertTrue([underTest applyMove:[JCSFlipMove moveWithStartRow:0 startColumn:1 direction:JCSHexDirectionW]], nil);
    
    // check that the game is over, and B won
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBWon, nil);
}

- (void)testMoveFailOnNoEmptyCellInDirection {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // hole at (2,3), A-B-A chain starting at (-1,0) and pointing northeast
        if (row == 2 && column == 3) {
            return JCSFlipCellStateHole;
        } else if ((row == -1 && column == 0) || (row == 1 && column == 2)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == 1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerBToMove cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNE]], nil);

    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];
}

- (void)testMoveFailOnGameOver {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        return JCSFlipCellStateOwnedByPlayerA;
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNE]], nil);
    
    // check that the game is still over
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAWon, nil);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];
}

- (void)testMoveSkip {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A at (-1,-1), B at remainder of row -1 and column -1
        if (row == -1 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == -1 || column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is valid
    STAssertTrue([underTest applyMove:[JCSFlipMove moveSkip]], nil);
    
    // check that the player has been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerBToMove, nil);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];
}

- (void)testMoveFailOnSkipNotAllowedMoveExists {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A at (-1,-1), empty at (-1,1), B at remainder of row -1 and column -1
        if (row == -1 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if ((row == -1 && column != 1) || column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is invalid
    STAssertFalse([underTest applyMove:[JCSFlipMove moveSkip]], nil);
    
    // check that the player has not been switched
    STAssertEquals(underTest.status, JCSFlipGameStatusPlayerAToMove, nil);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
    }];
}

- (void)testForAllNextStatesInvokeBlockOk {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // hole at (1,-2), A-B chain starting at (-1,0) and pointing NW, and A-B chain starting at (1,-3) and pointing SE
        if (row == 1 && column == -2) {
            return JCSFlipCellStateHole;
        } else if ((row == -1 && column == 0) || (row == 1 && column == -3)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if ((row == 0 && column == -1) || (row == 0 && column == -2)) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];

    // the possible moves for A are:
    // start at (-1,0) and move in any direction except NW
    // start at (1,-3) and move NE, SW, or SE
    
    NSMutableSet *expectedMoveStrings = [NSMutableSet set];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", -1, 0, JCSHexDirectionE]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", -1, 0, JCSHexDirectionNE]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", -1, 0, JCSHexDirectionW]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", -1, 0, JCSHexDirectionSW]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", -1, 0, JCSHexDirectionSE]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", 1, -3, JCSHexDirectionNE]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", 1, -3, JCSHexDirectionSW]];
    [expectedMoveStrings addObject:[NSString stringWithFormat:@"%d,%d %d", 1, -3, JCSHexDirectionSE]];
    
    // check the expected moves
    [underTest forAllNextStatesInvokeBlock:^(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop) {
        STAssertFalse(move.skip, nil);
        NSString *moveString = [NSString stringWithFormat:@"%d,%d %d", move.startRow, move.startColumn, move.direction];
        STAssertTrue([expectedMoveStrings containsObject:moveString], [NSString stringWithFormat:@"unexpected move string %@", moveString]);
        [expectedMoveStrings removeObject:moveString];
    }];

    // check the next state for the moves from (1,3) southwest
    [underTest forAllNextStatesInvokeBlock:^(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop) {
        if (move.startRow == 1 && move.startColumn == 3 && move.direction == JCSHexDirectionSW) {
            [nextState forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
                if ((row == -1 && column == 0) || (row == -1 && column == 1) || (row == 0 && column == 2) || (row == 1 && column == 3)) {
                    STAssertEquals(cellState, JCSFlipCellStateOwnedByPlayerA, nil);
                } else if (row == 0 && column == 1) {
                    STAssertEquals(cellState, JCSFlipCellStateOwnedByPlayerB, nil);
                } else {
                    STAssertEquals(cellState, JCSFlipCellStateEmpty, nil);
                }
            }];
        }
    }];
}

- (void)testForAllNextStatesInvokeBlockSkip {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A at (-1,-1), B at remainder of row -1 and column -1
        if (row == -1 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == -1 || column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
        
    // check that only skipping is possible for A
    __block NSInteger moveCount = 0;
    [underTest forAllNextStatesInvokeBlock:^(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop) {
        STAssertTrue(move.skip, nil);

        // expect exactly one next state
        moveCount++;
        STAssertTrue(moveCount == 1, nil);

        // check that cell states of the next state match the original state
        [nextState forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
            STAssertEquals(cellState, cellStateAtBlock(row, column), nil);
        }];
        
        // check that the player has been switched
        STAssertEquals(nextState.status, JCSFlipGameStatusPlayerBToMove, nil);
    }];
}

- (void)testForAllNextStatesInvokeBlockNoOwnedCells {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A not present on grid
        if (row == -1 || column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty; 
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    // check that nothing is possible for A
    [underTest forAllNextStatesInvokeBlock:^(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop) {
        STFail(nil);
    }];
}

- (void)testForAllNextStatesInvokeBlockNil {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        return JCSFlipCellStateEmpty; 
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    STAssertThrows([underTest forAllNextStatesInvokeBlock:nil], nil);
}

@end
