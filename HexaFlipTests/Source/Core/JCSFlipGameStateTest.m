//
//  JCSFlipGameStateTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipGameStatus.h"
#import "JCSFlipCellState.h"
#import "JCSHexDirection.h"
#import "JCSFlipMove.h"

@interface JCSFlipGameStateTest : XCTestCase
@end

@implementation JCSFlipGameStateTest

- (void)testInitSizeNegative {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
		return JCSFlipCellStateEmpty;
	};
    
    JCSFlipGameState *underTest;
    XCTAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:-1 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock]);
}

- (void)testInitCellStateAtBlockNil {
	JCSFlipGameState *underTest;
    XCTAssertThrows(underTest = [[JCSFlipGameState alloc] initWithSize:10 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:nil]);
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
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    XCTAssertEqual(underTest.status, JCSFlipGameStatusOpen);
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideB cellStateAtBlock:cellStateAtBlock];
    XCTAssertEqual(underTest.status, JCSFlipGameStatusOpen);
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
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlockA];
    XCTAssertEqual(underTest.status, JCSFlipGameStatusPlayerAWon);
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideB cellStateAtBlock:cellStateAtBlockB];
    XCTAssertEqual(underTest.status, JCSFlipGameStatusPlayerBWon);
    
    underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlockDraw];
    XCTAssertEqual(underTest.status, JCSFlipGameStatusDraw);
}

- (void)testInitInvokesCellStateAtBlock {
	// coordinates for which cellStateAtBlock has been called
	NSMutableSet *cellStateAtBlockCalledFor = [NSMutableSet set];
    
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        NSNumber *coordinate = @(1000*row+column);
        XCTAssertFalse([cellStateAtBlockCalledFor containsObject:coordinate]);
		[cellStateAtBlockCalledFor addObject:coordinate];
		return JCSFlipCellStateEmpty;
	};
    
	NSInteger size = 14;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
#pragma unused(underTest)
    
	// check that cellStateAtBlock is called for every coordinate
	XCTAssertEqual([cellStateAtBlockCalledFor count], (NSUInteger) ((2*size-1)*(2*size-1)));
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            NSInteger r3 = abs(row * column) % 3;
            NSInteger r4 = abs(row * column) % 4;
            
            // check cell state (verifies that cellStateAt behaves as expected)
            if (r4 == 0) {
                JCSFlipCellState expectedState = JCSFlipCellStateHole;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else if (r3 == 1) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else if (r3 == 2) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerB;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else {
                JCSFlipCellState expectedState = JCSFlipCellStateEmpty;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            }
        }
    }
}

- (void)testCellStateOutsideRange {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
		return JCSFlipCellStateEmpty;
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:3 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    JCSFlipCellState expectedState = JCSFlipCellStateHole;
    XCTAssertEqual([underTest cellStateAtRow:-3 column:0], expectedState);
    XCTAssertEqual([underTest cellStateAtRow:3 column:0], expectedState);
    XCTAssertEqual([underTest cellStateAtRow:0 column:-3], expectedState);
    XCTAssertEqual([underTest cellStateAtRow:0 column:3], expectedState);
}

- (void)testInvokeForAllCells {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == -1 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else if (row == 0 && column == 1) {
            return JCSFlipCellStateHole;
        }
		return JCSFlipCellStateEmpty;
	};
    
    NSInteger size = 3;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    NSMutableSet *visitorBlockCalledFor = [NSMutableSet set];
    
    BOOL(^visitorBlock)(NSInteger, NSInteger, JCSFlipCellState) = ^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        NSNumber *coordinate = @(1000*row+column);
        XCTAssertFalse([visitorBlockCalledFor containsObject:coordinate]);
        [visitorBlockCalledFor addObject:coordinate];
        
        // check for correct state
        if (row == 0 && column == 0) {
            JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerA;
            XCTAssertEqual(cellState, expectedState);
        } else if (row == -1 && column == 0) {
            JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerB;
            XCTAssertEqual(cellState, expectedState);
        } else if (row == 0 && column == 1) {
            JCSFlipCellState expectedState = JCSFlipCellStateHole;
            XCTAssertEqual(cellState, expectedState);
        } else {
            JCSFlipCellState expectedState = JCSFlipCellStateEmpty;
            XCTAssertEqual(cellState, expectedState);
        }
        
        return YES;
    };
    
    [underTest forAllCellsInvokeBlock:visitorBlock];
    
	XCTAssertEqual([visitorBlockCalledFor count], (NSUInteger) ((2*size-1)*(2*size-1)));
}

- (void)testInvokeForAllCellsStops {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
		return JCSFlipCellStateEmpty;
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:10 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    BOOL(^visitorBlock)(NSInteger row, NSInteger column, JCSFlipCellState);
    __block NSInteger visitorBlockCalledCount;
    
    visitorBlockCalledCount = 0;
    visitorBlock = ^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        visitorBlockCalledCount++;
        // fail if called more than 14 times
        XCTAssertTrue(visitorBlockCalledCount <= 14);
        // return NO if called for the 14th time
        return visitorBlockCalledCount < 14;
    };
    [underTest forAllCellsInvokeBlock:visitorBlock];
    
    visitorBlockCalledCount = 0;
    visitorBlock = ^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        visitorBlockCalledCount++;
        // fail if called more than 9 times
        XCTAssertTrue(visitorBlockCalledCount <= 9);
        // return NO if called for the 9th time
        return visitorBlockCalledCount < 9;
    };
    [underTest forAllCellsInvokeBlock:visitorBlock];
}

- (void)testPushMoveOk {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is valid
    XCTAssertTrue([underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNW]]);
    XCTAssertEqual(underTest.moveStackSize, 1u);
    
    // check that the player has been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    
    // check that cells states are modified correctly
    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            // A-A-B-A chain starting at (-1,0) and pointing NW
            if ((row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3)) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else if (row == 1 && column == -2) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerB;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else {
                JCSFlipCellState expectedState = JCSFlipCellStateEmpty;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            }
        }
    }
    
    // verify that move is valid
    XCTAssertTrue([underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionE]]);
    XCTAssertEqual(underTest.moveStackSize, 2u);
    
    // check that the player has been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    
    // check that cells states are modified correctly
    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            // A-A-B-A chain starting at (-1,0) and pointing NW, and B at (1,-1)
            if ((row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3)) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else if ((row == 1 && column == -1) || (row == 1 && column == -2)) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerB;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else {
                JCSFlipCellState expectedState = JCSFlipCellStateEmpty;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            }
        }
    }
}

- (void)testPushMoveStartCellStateMismatch {
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
	underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:0 startColumn:1 direction:JCSHexDirectionNE]]);
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    // check that move stack is still empty
    XCTAssertEqual(underTest.moveStackSize, 0u);
    
    // case 2: cell empty, player A to move
    underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:0 direction:JCSHexDirectionNE]]);
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    // check that move stack is still empty
    XCTAssertEqual(underTest.moveStackSize, 0u);
    
    // case 3: cell hole, player A to move
    underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:-2 startColumn:0 direction:JCSHexDirectionNE]]);
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    // check that move stack is still empty
    XCTAssertEqual(underTest.moveStackSize, 0u);
    
    // case 4: cell owned by A, player B to move
	underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideB cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNE]]);
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    // check that move stack is still empty
    XCTAssertEqual(underTest.moveStackSize, 0u);
    
    // case 5: cell empty, player B to move
	underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideB cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:-2 startColumn:0 direction:JCSHexDirectionNE]]);
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    // check that move stack is still empty
    XCTAssertEqual(underTest.moveStackSize, 0u);
    
    // case 6: cell hole, player A to move
    underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideB cellStateAtBlock:cellStateAtBlock];
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:-2 startColumn:0 direction:JCSHexDirectionNE]]);
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    // check that move stack is still empty
    XCTAssertEqual(underTest.moveStackSize, 0u);
}

- (void)testPushMoveGameOverAfterLastMove {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        if (row == 0 && column == 1) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == 0) {
            return JCSFlipCellStateEmpty;
        } else {
            return JCSFlipCellStateOwnedByPlayerB;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is invalid
    XCTAssertTrue([underTest pushMove:[JCSFlipMove moveWithStartRow:0 startColumn:1 direction:JCSHexDirectionW]]);
    
    // check that the game is over, and B won
    XCTAssertEqual(underTest.status, JCSFlipGameStatusPlayerBWon);
}

- (void)testPushMoveFailOnNoEmptyCellInDirection {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideB cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNE]]);
    
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
}

- (void)testPushMoveFailOnGameOver {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        return JCSFlipCellStateOwnedByPlayerA;
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that move is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNE]]);
    
    // check that the game is still over
    XCTAssertEqual(underTest.status, JCSFlipGameStatusPlayerAWon);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
}

- (void)testPushMoveSkip {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is valid
    XCTAssertTrue([underTest pushMove:[JCSFlipMove moveSkip]]);
    
    // check that the player has been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
}

- (void)testPushMoveFailOnSkipNotAllowedMoveExists {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is invalid
    XCTAssertFalse([underTest pushMove:[JCSFlipMove moveSkip]]);
    
    // check that the player has not been switched
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    
    // check that cell states are unmodified
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
}

- (void)testPopMoveOk {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push two moves, pop the last one
    [underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionNW]];
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionW]];
    XCTAssertEqual(underTest.moveStackSize, 2u);
    [underTest popMove];
    XCTAssertEqual(underTest.moveStackSize, 1u);
    
    // check that the player has been switched back
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
    
    // check that cells states are modified back correctly
    for (int row = -size+1; row < size; row++) {
        for (int column = -size+1; column < size; column++) {
            // A-A-B-A chain starting at (-1,0) and pointing NW
            if ((row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3)) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else if (row == 1 && column == -2) {
                JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerB;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            } else {
                JCSFlipCellState expectedState = JCSFlipCellStateEmpty;
                XCTAssertEqual([underTest cellStateAtRow:row column:column], expectedState);
            }
        }
    }
}

- (void)testPopMoveFailEmptyStack {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    XCTAssertThrows([underTest popMove]);
}

- (void)testSkipAllowed {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is valid
    XCTAssertTrue(underTest.skipAllowed);
}

- (void)skipNotAllowedMoveExists {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is invalid
    XCTAssertFalse(underTest.skipAllowed);
}

- (void)testSkipNotAllowedGameOver {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // some full board
        if (row == -1 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else {
            return JCSFlipCellStateOwnedByPlayerB;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // verify that skip is invalid
    XCTAssertFalse(underTest.skipAllowed);
}

- (NSString *)stringForMoveWithStartRow:(NSInteger)row column:(NSInteger)column direction:(JCSHexDirection)direction {
    return [NSString stringWithFormat:@"(%d,%d)-%@", row, column, JCSHexDirectionName(direction)];
}

- (void)testApplyAllPossibleMovesAndInvokeBlockOk {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // the possible moves for A are:
    // start at (-1,0) and move in any direction except NW
    // start at (1,-3) and move NE, SW, or SE
    
    NSMutableSet *expectedMoveStrings = [NSMutableSet set];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:-1 column:0 direction:JCSHexDirectionE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:-1 column:0 direction:JCSHexDirectionNE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:-1 column:0 direction:JCSHexDirectionW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:-1 column:0 direction:JCSHexDirectionSW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:-1 column:0 direction:JCSHexDirectionSE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:1 column:-3 direction:JCSHexDirectionNE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:1 column:-3 direction:JCSHexDirectionSW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:1 column:-3 direction:JCSHexDirectionSE]];
    
    // check the expected moves
    [underTest applyAllPossibleMovesAndInvokeBlock:^BOOL(JCSFlipMove *move) {
        XCTAssertFalse(move.skip);
        NSString *moveString = [self stringForMoveWithStartRow:move.startRow column:move.startColumn direction:move.direction];
        XCTAssertTrue([expectedMoveStrings containsObject:moveString], @"unexpected move string %@", moveString);
        [expectedMoveStrings removeObject:moveString];
        XCTAssertEqual(underTest.moveStackSize, 1u);
        return YES;
    }];
    
    // check that move stack is empty again
    XCTAssertEqual(underTest.moveStackSize, 0u);
    
    // check that all moves have been considered
    XCTAssertTrue(expectedMoveStrings.count == 0);
    
    // check the next state for the moves from (1,3) southwest
    [underTest applyAllPossibleMovesAndInvokeBlock:^BOOL(JCSFlipMove *move) {
        if (move.startRow == 1 && move.startColumn == 3 && move.direction == JCSHexDirectionSW) {
            [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
                if ((row == -1 && column == 0) || (row == -1 && column == 1) || (row == 0 && column == 2) || (row == 1 && column == 3)) {
                    XCTAssertEqual(cellState, JCSFlipCellStateOwnedByPlayerA);
                } else if (row == 0 && column == 1) {
                    XCTAssertEqual(cellState, JCSFlipCellStateOwnedByPlayerB);
                } else {
                    XCTAssertEqual(cellState, JCSFlipCellStateEmpty);
                }
                return YES;
            }];
        }
        return YES;
    }];
    
    // check that the state is changed back properly
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    XCTAssertEqual(underTest.cellCountPlayerA, 2);
    XCTAssertEqual(underTest.cellCountPlayerB, 2);
    XCTAssertEqual(underTest.cellCountEmpty, 44);
}

- (void)testApplyAllPossibleMovesAndInvokeBlockNoFlipOnlyOnce {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // B-A chain starting at (-1,0) and pointing NW, and B-A chain starting at (1,-3) and pointing SE
        if ((row == 0 && column == -1) || (row == 0 && column == -2)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if ((row == -1 && column == 0) || (row == 1 && column == -3)) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // the possible moves for A are:
    // start at (0,-2) and move in any direction except NW
    // start at (0,-1) and move in any direction
    
    NSMutableSet *expectedMoveStrings = [NSMutableSet set];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionNE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionSW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionSE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionNE]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionNW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionSW]];
    [expectedMoveStrings addObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionSE]];
    
    // check the expected moves
    [underTest applyAllPossibleMovesAndInvokeBlock:^BOOL(JCSFlipMove *move) {
        XCTAssertFalse(move.skip);
        NSString *moveString = [self stringForMoveWithStartRow:move.startRow column:move.startColumn direction:move.direction];
        XCTAssertTrue([expectedMoveStrings containsObject:moveString], @"unexpected move string %@", moveString);
        [expectedMoveStrings removeObject:moveString];
        return YES;
    }];
    
    // the possible no-flip moves for A are:
    // start at (0,-2) and move SE (target (-1,-1))
    // start at (0,-2) and move NE (target (1,-2))
    // start at (0,-1) and move SW (target (-1,-1))
    // start at (0,-1) and move NW (target (1,-2))
    
    // check that exactly one of the no-flip moves with the same target has been considered
    BOOL noFlip1aRemoved = ![expectedMoveStrings containsObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionSE]];
    BOOL noFlip1bRemoved = ![expectedMoveStrings containsObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionSW]];
    XCTAssertTrue(noFlip1aRemoved ^ noFlip1bRemoved);
    
    BOOL noFlip2aRemoved = ![expectedMoveStrings containsObject:[self stringForMoveWithStartRow:0 column:-2 direction:JCSHexDirectionNE]];
    BOOL noFlip2bRemoved = ![expectedMoveStrings containsObject:[self stringForMoveWithStartRow:0 column:-1 direction:JCSHexDirectionNW]];
    XCTAssertTrue(noFlip2aRemoved ^ noFlip2bRemoved);
    
    // check that all other moves have been considered
    XCTAssertTrue(expectedMoveStrings.count == 2);
    
    // check that the state is changed back properly
    [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideA);
    XCTAssertEqual(underTest.cellCountPlayerA, 2);
    XCTAssertEqual(underTest.cellCountPlayerB, 2);
    XCTAssertEqual(underTest.cellCountEmpty, 45);
}

- (void)testApplyAllPossibleMovesAndInvokeBlockSkip {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // check that only skipping is possible for A
    __block NSInteger moveCount = 0;
    [underTest applyAllPossibleMovesAndInvokeBlock:^BOOL(JCSFlipMove *move) {
        XCTAssertTrue(move.skip);
        
        // expect exactly one next state
        moveCount++;
        XCTAssertTrue(moveCount == 1);
        
        // check that cell states of the next state match the original state
        [underTest forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
            XCTAssertEqual(cellState, cellStateAtBlock(row, column));
            return YES;
        }];
        
        // check that the player has been switched
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSideB);
        
        return YES;
    }];
}

- (void)testApplyAllPossibleMovesAndInvokeBlockNil {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        return JCSFlipCellStateEmpty;
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    XCTAssertThrows([underTest applyAllPossibleMovesAndInvokeBlock:nil]);
}

- (void)testForAllCellsInvolvedInLastMoveInvokeBlockOk {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
    NSInteger size = 4;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push move
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    
    // create invocation checker
    __block NSInteger invocation = 0;
    BOOL(^block)(NSInteger, NSInteger, JCSFlipCellState, JCSFlipCellState) = ^BOOL(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState) {
        JCSFlipCellState expectedState;
        switch (++invocation) {
            case 1:
                XCTAssertEqual(row, 1);
                XCTAssertEqual(column, -2);
                expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 2:
                XCTAssertEqual(row, 0);
                XCTAssertEqual(column, -1);
                expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 3:
                XCTAssertEqual(row, -1);
                XCTAssertEqual(column, 0);
                expectedState = JCSFlipCellStateOwnedByPlayerB;
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 4:
                XCTAssertEqual(row, -2);
                XCTAssertEqual(column, 1);
                expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual(newCellState, expectedState);
                break;
            default:
                XCTFail(@"unexpected invocation");
        }
        return YES;
    };
    
    [underTest forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:block];
}

- (void)testForAllCellsInvolvedInLastMoveInvokeBlockReverseOk {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
    NSInteger size = 4;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push move
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    
    // create invocation checker
    __block NSInteger invocation = 0;
    BOOL(^block)(NSInteger, NSInteger, JCSFlipCellState, JCSFlipCellState) = ^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState) {
        JCSFlipCellState expectedState;
        switch (++invocation) {
            case 1:
                XCTAssertEqual(row, -2);
                XCTAssertEqual(column, 1);
                expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 2:
                XCTAssertEqual(row, -1);
                XCTAssertEqual(column, 0);
                expectedState = JCSFlipCellStateOwnedByPlayerB;
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 3:
                XCTAssertEqual(row, 0);
                XCTAssertEqual(column, -1);
                expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 4:
                XCTAssertEqual(row, 1);
                XCTAssertEqual(column, -2);
                expectedState = JCSFlipCellStateOwnedByPlayerA;
                XCTAssertEqual(newCellState, expectedState);
                break;
            default:
                XCTFail(@"unexpected invocation");
        }
        return YES;
    };
    
    [underTest forAllCellsInvolvedInLastMoveReverse:YES invokeBlock:block];
}

- (void)testForAllCellsInvolvedInLastMoveInvokeBlockSkip {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    
    // push skip
    XCTAssertTrue([underTest pushMove:[JCSFlipMove moveSkip]]);
    
    // create invocation checker
    BOOL(^block)(NSInteger, NSInteger, JCSFlipCellState, JCSFlipCellState) = ^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState) {
        XCTFail(@"unexpected invocation");
        return YES;
    };
    
    [underTest forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:block];
}

- (void)testForAllCellsInvolvedInLastMoveInvokeBlockStop {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
    NSInteger size = 4;
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:size playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push move
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    
    // create invocation checker
    __block NSInteger invocation = 0;
    BOOL(^block)(NSInteger, NSInteger, JCSFlipCellState, JCSFlipCellState) = ^BOOL(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState) {
        JCSFlipCellState expectedState = JCSFlipCellStateOwnedByPlayerA;
        switch (++invocation) {
            case 1:
                XCTAssertEqual(row, 1);
                XCTAssertEqual(column, -2);
                XCTAssertEqual(newCellState, expectedState);
                break;
            case 2:
                XCTAssertEqual(row, 0);
                XCTAssertEqual(column, -1);
                XCTAssertEqual(newCellState, expectedState);
                // now stop!
                return NO;
            default:
                XCTFail(@"unexpected invocation");
        }
        return YES;
    };
    
    [underTest forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:block];
}

- (void)testForAllCellsInvolvedInLastMoveInvokeBlockBlockNil {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    XCTAssertThrows([underTest forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:nil]);
}

- (void)testForAllCellsInvolvedInLastMoveInvokeBlockStackEmpty {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    BOOL(^block)(NSInteger, NSInteger, JCSFlipCellState, JCSFlipCellState) = ^BOOL(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState) {
        XCTFail(@"unexpected invocation");
        return YES;
    };
    
    XCTAssertThrows([underTest forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:block]);
}

- (void)testCoding {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push some moves
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionE]];
    [underTest pushMove:[JCSFlipMove moveWithStartRow:0 startColumn:-1 direction:JCSHexDirectionNW]];
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-1 direction:JCSHexDirectionW]];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:underTest];
    
    JCSFlipGameState *reloaded = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // check properties
    XCTAssertEqual(reloaded.status, underTest.status);
    XCTAssertEqual(reloaded.cellCountPlayerA, underTest.cellCountPlayerA);
    XCTAssertEqual(reloaded.cellCountPlayerB, underTest.cellCountPlayerB);
    XCTAssertEqual(reloaded.cellCountEmpty, underTest.cellCountEmpty);
    XCTAssertEqual(reloaded.zobristHash, underTest.zobristHash);
    
    // check cell states (must be match original board)
    [reloaded forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, [underTest cellStateAtRow:row column:column]);
        return YES;
    }];
    
    // undo moves
    for (NSInteger i = 0; i < 3; i++) {
        [reloaded popMove];
        [underTest popMove];
        
        // check cell states (must match)
        [reloaded forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
            XCTAssertEqual(cellState, [underTest cellStateAtRow:row column:column]);
            return YES;
        }];
    }
    
    // check cell states (must be back to original)
    [reloaded forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, cellStateAtBlock(row, column));
        return YES;
    }];
    
    // check that move stack is empty
    XCTAssertThrows([reloaded popMove]);
}

- (void)testCodingWithLimitedStack {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push some moves
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    [underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionW]];
    [underTest pushMove:[JCSFlipMove moveWithStartRow:0 startColumn:-1 direction:JCSHexDirectionNE]];
    XCTAssertEqual(underTest.moveStackSize, 3u);
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [underTest encodeWithCoder:coder maxMoves:2];
    [coder finishEncoding];
    
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    JCSFlipGameState *reloaded = [underTest initWithCoder:decoder];
    
    // check properties
    XCTAssertEqual(reloaded.status, underTest.status);
    XCTAssertEqual(reloaded.cellCountPlayerA, underTest.cellCountPlayerA);
    XCTAssertEqual(reloaded.cellCountPlayerB, underTest.cellCountPlayerB);
    XCTAssertEqual(reloaded.cellCountEmpty, underTest.cellCountEmpty);
    XCTAssertEqual(reloaded.zobristHash, underTest.zobristHash);
    XCTAssertEqual(reloaded.moveStackSize, 2u);
    
    // check cell states (must be match original board)
    [reloaded forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, [underTest cellStateAtRow:row column:column]);
        return YES;
    }];
    
    // undo the two moves that have been coded
    [reloaded popMove];
    [reloaded popMove];
    
    // check that move stack is empty
    XCTAssertThrows([reloaded popMove]);
}

- (void)testCodingEmptyMoveStack {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:underTest];
    
    JCSFlipGameState *reloaded = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // check properties
    XCTAssertEqual(reloaded.status, underTest.status);
    XCTAssertEqual(reloaded.cellCountPlayerA, underTest.cellCountPlayerA);
    XCTAssertEqual(reloaded.cellCountPlayerB, underTest.cellCountPlayerB);
    XCTAssertEqual(reloaded.cellCountEmpty, underTest.cellCountEmpty);
    XCTAssertEqual(reloaded.zobristHash, underTest.zobristHash);
    
    // check cell states (must be match original board)
    [reloaded forAllCellsInvokeBlock:^BOOL(NSInteger row, NSInteger column, JCSFlipCellState cellState) {
        XCTAssertEqual(cellState, [underTest cellStateAtRow:row column:column]);
        return YES;
    }];
    
    // check that move stack is empty
    XCTAssertThrows([reloaded popMove]);
}

- (void)testLastMove {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push/pop some moves and check the last move
    JCSFlipMove *lastMove;
    
    lastMove = underTest.lastMove;
    XCTAssertNil(lastMove);
    
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    lastMove = underTest.lastMove;
    XCTAssertFalse(lastMove.skip);
    XCTAssertEqual(lastMove.startRow, 1);
    XCTAssertEqual(lastMove.startColumn, -2);
    XCTAssertEqual(lastMove.direction, JCSHexDirectionSE);
    
    [underTest pushMove:[JCSFlipMove moveWithStartRow:-1 startColumn:0 direction:JCSHexDirectionW]];
    lastMove = underTest.lastMove;
    XCTAssertFalse(lastMove.skip);
    XCTAssertEqual(lastMove.startRow, -1);
    XCTAssertEqual(lastMove.startColumn, 0);
    XCTAssertEqual(lastMove.direction, JCSHexDirectionW);
    
    [underTest popMove];
    lastMove = underTest.lastMove;
    XCTAssertFalse(lastMove.skip);
    XCTAssertEqual(lastMove.startRow, 1);
    XCTAssertEqual(lastMove.startColumn, -2);
    XCTAssertEqual(lastMove.direction, JCSHexDirectionSE);
    
    [underTest popMove];
    lastMove = underTest.lastMove;
    XCTAssertNil(lastMove);
}

- (void)testLastMoveSkip {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        //    A
        // O B
        if ((row == 1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == 0) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateEmpty;
        } else {
            return JCSFlipCellStateHole;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    // push/pop skip move and check the last move
    JCSFlipMove *lastMove;
    
    lastMove = underTest.lastMove;
    XCTAssertNil(lastMove);
    
    [underTest pushMove:[JCSFlipMove moveSkip]];
    lastMove = underTest.lastMove;
    XCTAssertTrue(lastMove.skip);
    
    [underTest popMove];
    lastMove = underTest.lastMove;
    XCTAssertNil(lastMove);
}

- (void)testZobristHashChangedByPushMoveNormal {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    NSUInteger zobristBefore = underTest.zobristHash;
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    XCTAssertFalse(underTest.zobristHash == zobristBefore, @"hash value did not change as expected");
}

- (void)testZobristHashChangedByPushMoveSkip {
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
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:2 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    NSUInteger zobristBefore = underTest.zobristHash;
    [underTest pushMove:[JCSFlipMove moveSkip]];
    XCTAssertFalse(underTest.zobristHash == zobristBefore, @"hash value did not change as expected");
}

- (void)testZobristHashRevertedByPopMove {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        // A-B-A chain starting at (1,-2) and pointing SE
        if ((row == 1 && column == -2) || (row == -1 && column == 0)) {
            return JCSFlipCellStateOwnedByPlayerA;
        } else if (row == 0 && column == -1) {
            return JCSFlipCellStateOwnedByPlayerB;
        } else {
            return JCSFlipCellStateEmpty;
        }
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    NSUInteger zobristBefore = underTest.zobristHash;
    [underTest pushMove:[JCSFlipMove moveWithStartRow:1 startColumn:-2 direction:JCSHexDirectionSE]];
    [underTest popMove];
    XCTAssertEqual(underTest.zobristHash, zobristBefore);
}

@end
