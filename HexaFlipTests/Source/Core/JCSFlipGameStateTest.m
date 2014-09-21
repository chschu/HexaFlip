//
//  JCSFlipGameStateTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipCellState.h"

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

- (void)testApplyAllPossibleMovesAndInvokeBlockNil {
	JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        return JCSFlipCellStateEmpty;
	};
    
	JCSFlipGameState *underTest = [[JCSFlipGameState alloc] initWithSize:4 playerToMove:JCSFlipPlayerSideA cellStateAtBlock:cellStateAtBlock];
    
    XCTAssertThrows([underTest applyAllPossibleMovesAndInvokeBlock:nil]);
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

@end
