//
//  JCSFlipMoveTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 14.09.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import XCTest

class JCSFlipMoveTest : XCTestCase {
    
    func testInitNormalMove() {
        let move = JCSFlipMove(startRow: 1, startColumn: 4, direction: JCSHexDirection.NE)
        
        XCTAssertFalse(move.skip)
        XCTAssertEqual(move.startRow, 1)
        XCTAssertEqual(move.startColumn, 4)
        XCTAssertEqual(move.direction, JCSHexDirection.NE)
    }
    
    func testInitSkipMove() {
        let move = JCSFlipMove()
        
        XCTAssertTrue(move.skip)
    }
    
    func testMutable() {
        let move = JCSFlipMove()
        
        move.skip = false
        move.startRow = 1
        move.startColumn = 2
        move.direction = JCSHexDirection.NW
        
        XCTAssertFalse(move.skip)
        XCTAssertEqual(move.startRow, 1)
        XCTAssertEqual(move.startColumn, 2)
        XCTAssertEqual(move.direction, JCSHexDirection.NW)
    }
    
    func testCopy() {
        let move = JCSFlipMove(startRow: 32, startColumn: 12, direction:JCSHexDirection.E)
        
        let copy = move.copy() as JCSFlipMove
        
        XCTAssertTrue(move !== copy)
        XCTAssertTrue(move.isKindOfClass(JCSFlipMove))
        XCTAssertEqual(move.skip, copy.skip)
        XCTAssertEqual(move.startRow, copy.startRow)
        XCTAssertEqual(move.startColumn, copy.startColumn)
        XCTAssertEqual(move.direction, copy.direction)
    }
    
    func testPerformInputWhenNormalMove() {
        let move = JCSFlipMove(startRow: 17, startColumn: 23, direction: JCSHexDirection.NW)
        let delegate = MockDelegate(expectedMove: move, expectation: expectationWithDescription("invocation sequence"))
        
        move.performInputWithMoveInputDelegate(delegate)
        
        waitForExpectationsWithTimeout(0.55, nil)
    }
    
    func testPerformInputWhenSkipMove() {
        let move = JCSFlipMove()
        let delegate = MockDelegate(expectedMove: move, expectation: expectationWithDescription("invocation sequence"))
        
        move.performInputWithMoveInputDelegate(delegate)
        
        waitForExpectationsWithTimeout(0.05, nil)
    }
    
    func testCompareToMoveByValueAscending() {
        let moveA = JCSFlipMove()
        moveA.value = 0.0
        let moveB = JCSFlipMove()
        moveB.value = 1.0
        
        XCTAssertEqual(moveA.compareByValueTo(moveB), NSComparisonResult.OrderedAscending, "expected move A < move B")
    }
    
    func testCompareToMoveByValueSame() {
        let moveA = JCSFlipMove()
        moveA.value = 1.23
        let moveB = JCSFlipMove()
        moveB.value = 1.23
        
        XCTAssertEqual(moveA.compareByValueTo(moveB), NSComparisonResult.OrderedSame, "expected move A = move B")
    }
    
    func testCompareToMoveByValueDescending() {
        let moveA = JCSFlipMove()
        moveA.value = 0.3
        let moveB = JCSFlipMove()
        moveB.value = -0.1
        
        XCTAssertEqual(moveA.compareByValueTo(moveB), NSComparisonResult.OrderedDescending, "expected move A > move B")
    }
    
    private class MockDelegate : NSObject, JCSFlipMoveInputDelegate {
        
        private enum Invocation : String {
            case SelectStartPoint = "select start point"
            case SelectDirection = "select direction"
            case ClearDirection = "clear direction"
            case ClearStartPoint = "clear start point"
            case Confirm = "confirm"
            case None = "none"
        }
        
        let expectedMove: JCSFlipMove
        let expectation: XCTestExpectation
        var nextInvocation: Invocation
        
        init(expectedMove: JCSFlipMove, expectation: XCTestExpectation) {
            self.expectedMove = expectedMove
            self.expectation = expectation
            self.nextInvocation = (expectedMove.skip ? Invocation.Confirm : Invocation.SelectStartPoint)
        }
        
        func inputSelectedStartRow(startRow: Int, startColumn: Int) -> Bool {
            XCTAssertEqual(nextInvocation, Invocation.SelectStartPoint, "unexpected invocation")
            XCTAssertEqual(startRow, expectedMove.startRow, "start row")
            XCTAssertEqual(startColumn, expectedMove.startColumn, "start column")
            nextInvocation = Invocation.SelectDirection
            return true
        }
        
        func inputClearedStartRow(startRow: Int, startColumn: Int) {
            XCTAssertEqual(nextInvocation, Invocation.ClearStartPoint, "unexpected invocation")
            XCTAssertEqual(startRow, expectedMove.startRow, "start row")
            XCTAssertEqual(startColumn, expectedMove.startColumn, "start column")
            nextInvocation = Invocation.Confirm
        }
        
        func inputModifiedStartRow(startRow: Int, startColumn: Int, previousStartRow: Int, previousStartColumn: Int) -> Bool {
            XCTFail("unexpected invocation")
            return true
        }
        
        func inputSelectedDirection(direction: JCSHexDirection, startRow: Int, startColumn:Int) {
            XCTAssertEqual(nextInvocation, Invocation.SelectDirection, "unexpected invocation")
            XCTAssertEqual(direction, expectedMove.direction, "direction")
            XCTAssertEqual(startRow, expectedMove.startRow, "start row")
            XCTAssertEqual(startColumn, expectedMove.startColumn, "start column")
            nextInvocation = Invocation.ClearDirection
        }
        
        func inputClearedDirection(direction: JCSHexDirection, startRow: Int, startColumn:Int) {
            XCTAssertEqual(nextInvocation, Invocation.ClearDirection, "unexpected invocation")
            XCTAssertEqual(direction, expectedMove.direction, "direction")
            XCTAssertEqual(startRow, expectedMove.startRow, "start row")
            XCTAssertEqual(startColumn, expectedMove.startColumn, "start column")
            nextInvocation = Invocation.ClearStartPoint
        }
        
        func inputCancelled() {
            XCTFail("unexpected invocation")
        }
        
        func inputConfirmedWithMove(move: JCSFlipMove) {
            XCTAssertEqual(nextInvocation, Invocation.Confirm, "unexpected invocation")
            XCTAssertEqual(move, expectedMove, "move")
            nextInvocation = Invocation.None
            expectation.fulfill()
        }
    }
}
