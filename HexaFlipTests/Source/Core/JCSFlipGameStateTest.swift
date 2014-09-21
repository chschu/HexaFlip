//
//  JCSFlipGameStateTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 27.09.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import XCTest

// make JCSFlipMove equatable and usable as Dictionary key
public func ==(lhs: JCSFlipMove, rhs: JCSFlipMove) -> Bool {
    return lhs.skip && rhs.skip || !lhs.skip && !rhs.skip && lhs.startRow == rhs.startRow && lhs.startColumn == rhs.startColumn && lhs.direction == rhs.direction
}
extension JCSFlipMove : Hashable {
    public override var hashValue: Int {
        var hash = 0
        hash = 31 &* hash + skip.hashValue
        hash = 31 &* hash + startRow.hashValue
        hash = 31 &* hash + startColumn.hashValue
        hash = 31 &* hash + direction.hashValue
        return hash
    }
}

class JCSFlipGameStateTest : XCTestCase {
    
    func testInitSetsStatusNormal() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            if row == 0 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if column == 0 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let stateWithPlayerAToMove = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        XCTAssertEqual(stateWithPlayerAToMove.status, JCSFlipGameStatus.Open)
        
        let stateWithPlayerBToMove = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.B, cellStateAtBlock: cellStateAtBlock)
        XCTAssertEqual(stateWithPlayerBToMove.status, JCSFlipGameStatus.Open)
    }
    
    func testInitSetsStateGameOver() {
        let stateWithPlayerAWon = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            return (row == 0 ? JCSFlipCellState.OwnedByPlayerA : JCSFlipCellState.Empty)
        }
        XCTAssertEqual(stateWithPlayerAWon.status, JCSFlipGameStatus.PlayerAWon)
        
        let stateWithPlayerBWon = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.B) { (row, column) -> JCSFlipCellState in
            return (row == 0 ? JCSFlipCellState.OwnedByPlayerB : JCSFlipCellState.Empty)
        }
        XCTAssertEqual(stateWithPlayerBWon.status, JCSFlipGameStatus.PlayerBWon)
        
        let stateWithDraw = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            let r0 = (row == 0)
            let c0 = (column == 0)
            return (r0 == c0 ? JCSFlipCellState.Hole : (r0 ? JCSFlipCellState.OwnedByPlayerA : JCSFlipCellState.OwnedByPlayerB))
        }
        XCTAssertEqual(stateWithDraw.status, JCSFlipGameStatus.Draw)
    }
    
    func testInitInvokesCellStateAtBlock() {
        // coordinates for which cellStateAtBlock has been called
        var cellStateAtBlockCalledFor: [String: Bool] = [:]
        let size = 14
        
        let underTest = JCSFlipGameState(size: size, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            let coordinate = "\(row):\(column)"
            XCTAssertNil(cellStateAtBlockCalledFor[coordinate])
            cellStateAtBlockCalledFor[coordinate] = true
            return JCSFlipCellState.Empty
        }
        
        // check that cellStateAtBlock is called for every coordinate
        XCTAssertEqual(cellStateAtBlockCalledFor.count, (2*size-1)*(2*size-1))
    }
    
    func testInitStoresCells() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            switch abs(row * column) % 4 {
            case 0:
                return JCSFlipCellState.Hole
            default:
                switch abs(row * column) % 3 {
                case 1:
                    return JCSFlipCellState.OwnedByPlayerA
                case 2:
                    return JCSFlipCellState.OwnedByPlayerB
                default:
                    return JCSFlipCellState.Empty
                }
            }
        }
        
        let underTest = JCSFlipGameState(size: 10, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(underTest.cellStateAtRow(row, column: column), cellStateAtBlock(row, column))
            return true
        }
    }
    
    func testCellStateOutsideRange() {
        let underTest = JCSFlipGameState(size: 3, playerToMove: JCSFlipPlayerSide.A) { (_, _) -> JCSFlipCellState in
            return JCSFlipCellState.Empty
        }
        
        XCTAssertEqual(underTest.cellStateAtRow(-3, column: 0), JCSFlipCellState.Hole)
        XCTAssertEqual(underTest.cellStateAtRow(3, column: 0), JCSFlipCellState.Hole)
        XCTAssertEqual(underTest.cellStateAtRow(0, column: -3), JCSFlipCellState.Hole)
        XCTAssertEqual(underTest.cellStateAtRow(0, column: 3), JCSFlipCellState.Hole)
    }
    
    func testInvokeForAllCells() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            if row == 0 && column == 0 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == -1 && column == 0 {
                return JCSFlipCellState.OwnedByPlayerB
            } else if row == 0 && column == 1 {
                return JCSFlipCellState.Hole
            } else {
                return JCSFlipCellState.Empty
            }
        }
        let size = 3
        let underTest = JCSFlipGameState(size: size, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        var visitorBlockCalledFor: [String:Bool] = [:]
        
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            let coordinate = "\(row):\(column)"
            XCTAssertNil(visitorBlockCalledFor[coordinate])
            visitorBlockCalledFor[coordinate] = true
            XCTAssertEqual(cellState, cellStateAtBlock(row, column))
            return true
        }
        
        XCTAssertEqual(visitorBlockCalledFor.count, (2*size-1)*(2*size-1))
    }
    
    func testInvokeForAllCellsStops() {
        let underTest = JCSFlipGameState(size: 10, playerToMove: JCSFlipPlayerSide.A)
        
        for maxExpectedCount in [0, 9, 14, 2000] {
            var visitorBlockCalledCount = 0
            
            underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
                // fail if called more than maxExpectedCount times
                XCTAssertTrue(visitorBlockCalledCount <= maxExpectedCount)
                // return NO if called for the maxExpectedCount-th time
                return visitorBlockCalledCount < maxExpectedCount
            }
        }
    }
    
    func testPushMoveOk() {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A-B-A chain starting at (-1,0) and pointing NW
            if (row == -1 && column == 0) || (row == 1 && column == -2) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // verify that move is valid
        XCTAssertTrue(underTest.pushMove(JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.NW)))
        XCTAssertEqual(underTest.moveStackSize, UInt(1))
        
        // check that the player has been switched
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.B)
        
        // check that cells states are modified correctly
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            let cellState = underTest.cellStateAtRow(row, column: column)
            // A-A-B-A chain starting at (-1,0) and pointing NW
            if (row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3) {
                XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerA)
            } else if row == 1 && column == -2 {
                XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerB)
            } else {
                XCTAssertEqual(cellState, JCSFlipCellState.Empty)
            }
            return true
        }
        
        // verify that move is valid
        XCTAssertTrue(underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.E)))
        XCTAssertEqual(underTest.moveStackSize, UInt(2))
        
        // check that the player has been switched
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.A)
        
        // check that cells states are modified correctly
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            // A-A-B-A chain starting at (-1,0) and pointing NW, and B at (1,-1)
            if (row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3) {
                XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerA)
            } else if (row == 1 && column == -1) || (row == 1 && column == -2) {
                XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerB)
            } else {
                XCTAssertEqual(cellState, JCSFlipCellState.Empty)
            }
            return true
        }
    }
    
    func testPushMoveStartCellStateMismatch() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // hole at (-2,0), A-B-A chain starting at (-1,0) and pointing northeast
            if row == -2 && column == 0 {
                return JCSFlipCellState.Hole
            } else if (row == -1 && column == 0) || (row == 1 && column == 2) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == 1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let testSets: [(playerToMove: JCSFlipPlayerSide, move: JCSFlipMove)] = [
            // case 1: cell owned by B, player A to move
            (JCSFlipPlayerSide.A, JCSFlipMove(startRow: 0, startColumn: 1, direction: JCSHexDirection.NE)),
            // case 2: cell empty, player A to move
            (JCSFlipPlayerSide.A, JCSFlipMove(startRow: 1, startColumn: 0, direction: JCSHexDirection.NE)),
            // case 3: cell hole, player A to move
            (JCSFlipPlayerSide.A, JCSFlipMove(startRow: -2, startColumn: 0, direction: JCSHexDirection.NE)),
            // case 4: cell owned by A, player B to move
            (JCSFlipPlayerSide.B, JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.NE)),
            // case 5: cell empty, player B to move
            (JCSFlipPlayerSide.B, JCSFlipMove(startRow: 1, startColumn: 0, direction: JCSHexDirection.NE)),
            // case 6: cell hole, player B to move
            (JCSFlipPlayerSide.B, JCSFlipMove(startRow: -2, startColumn: 0, direction: JCSHexDirection.NE))
        ]
        
        for testSet in testSets {
            let underTest = JCSFlipGameState(size: 4, playerToMove: testSet.playerToMove, cellStateAtBlock: cellStateAtBlock)
            // verify that move is invalid
            XCTAssertFalse(underTest.pushMove(testSet.move))
            // check that the player has not been switched
            XCTAssertEqual(underTest.playerToMove, testSet.playerToMove)
            // check that cell states are unmodified
            underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
                XCTAssertEqual(cellState, cellStateAtBlock(row, column))
                return true
            }
            // check that move stack is still empty
            XCTAssertEqual(underTest.moveStackSize, UInt(0))
        }
    }
    
    func testPushMoveGameOverAfterLastMove() {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            if row == 0 && column == 1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == 0 {
                return JCSFlipCellState.Empty
            } else {
                return JCSFlipCellState.OwnedByPlayerB
            }
        }
        
        // verify that move is valid
        XCTAssertTrue(underTest.pushMove(JCSFlipMove(startRow: 0, startColumn: 1, direction: JCSHexDirection.W)))
        
        // check that the game is over, and B won
        XCTAssertEqual(underTest.status, JCSFlipGameStatus.PlayerBWon)
    }
    
    func testPushMoveSkip() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // A at (-1,-1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == -1 || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        
        // verify that skip is valid
        XCTAssertTrue(underTest.pushMove(JCSFlipMove()))
        
        // check that the player has been switched
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.B)
        
        // check that cell states are unmodified
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(cellState, cellStateAtBlock(row, column))
            return true
        }
    }
    
    func testPushMoveFail(move: JCSFlipMove, size: Int, playerToMove: JCSFlipPlayerSide, cellStateAtBlock: (Int, Int) -> JCSFlipCellState) {
        let underTest = JCSFlipGameState(size: size, playerToMove: playerToMove, cellStateAtBlock: cellStateAtBlock)
        
        // verify that move is invalid
        XCTAssertFalse(underTest.pushMove(move))
        
        // check that the player has not been switched
        XCTAssertEqual(underTest.playerToMove, playerToMove)
        
        // check that cell states are unmodified
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(cellState, cellStateAtBlock(row, column))
            return true
        }
    }
    
    func testPushMoveFailOnNoEmptyCellInDirection() {
        testPushMoveFail(JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.NE), size: 4, playerToMove: JCSFlipPlayerSide.B) { (row, column) -> JCSFlipCellState in
            // hole at (2,3), A-B-A chain starting at (-1,0) and pointing northeast
            if row == 2 && column == 3 {
                return JCSFlipCellState.Hole
            } else if (row == -1 && column == 0) || (row == 1 && column == 2) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == 1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
    }
    
    func testPushMoveFailOnGameOver() {
        testPushMoveFail(JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.NE), size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            return JCSFlipCellState.OwnedByPlayerA
        }
    }
    
    func testPushMoveFailOnSkipNotAllowedMoveExists() {
        testPushMoveFail(JCSFlipMove(), size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A at (-1,-1), empty at (-1,1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if (row == -1 && column != 1) || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
    }
    
    func testPopMoveOk() {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A-B-A chain starting at (-1,0) and pointing NW
            if (row == -1 && column == 0) || (row == 1 && column == -2) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // push two moves, pop the last one
        underTest.pushMove(JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.NW))
        underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.W))
        XCTAssertEqual(underTest.moveStackSize, UInt(2))
        underTest.popMove()
        XCTAssertEqual(underTest.moveStackSize, UInt(1))
        
        // check that the player has been switched back
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.B)
        
        // check that cells states are modified back correctly
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            // A-A-B-A chain starting at (-1,0) and pointing NW
            if (row == -1 && column == 0) || (row == 0 && column == -1) || (row == 2 && column == -3) {
                XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerA)
            } else if row == 1 && column == -2 {
                XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerB)
            } else {
                XCTAssertEqual(cellState, JCSFlipCellState.Empty)
            }
            return true
        }
    }
    
    
    func testSkipAllowed() {
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A at (-1,-1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == -1 || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // verify that skip is valid
        XCTAssertTrue(underTest.skipAllowed)
    }
    
    func testSkipNotAllowedMoveExists() {
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A at (-1,-1), empty at (-1,1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if (row == -1 && column != 1) || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // verify that skip is invalid
        XCTAssertFalse(underTest.skipAllowed)
    }
    
    func testSkipNotAllowedGameOver() {
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // some full board
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else {
                return JCSFlipCellState.OwnedByPlayerB
            }
        }
        
        // verify that skip is invalid
        XCTAssertFalse(underTest.skipAllowed)
    }
    
    func testApplyAllPossibleMovesAndInvokeBlockOk() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // hole at (1,-2), A-B chain starting at (-1,0) and pointing NW, and A-B chain starting at (1,-3) and pointing SE
            if row == 1 && column == -2 {
                return JCSFlipCellState.Hole
            } else if (row == -1 && column == 0) || (row == 1 && column == -3) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if (row == 0 && column == -1) || (row == 0 && column == -2) {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        
        // the possible moves for A are:
        // start at (-1,0) and move in any direction except NW
        // start at (1,-3) and move NE, SW, or SE
        // only the keys of this dictionary are used
        var expectedMoves = [
            JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.E):0,
            JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.NE):0,
            JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.W):0,
            JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.SW):0,
            JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.SE):0,
            JCSFlipMove(startRow: 1, startColumn: -3, direction: JCSHexDirection.NE):0,
            JCSFlipMove(startRow: 1, startColumn: -3, direction: JCSHexDirection.SW):0,
            JCSFlipMove(startRow: 1, startColumn: -3, direction: JCSHexDirection.SE):0
        ]
        
        // check the expected moves
        underTest.applyAllPossibleMovesAndInvokeBlock { (move) -> Bool in
            XCTAssertNotNil(move)
            let flipMove = move as JCSFlipMove
            XCTAssertTrue(expectedMoves.indexForKey(flipMove) != nil)
            expectedMoves.removeValueForKey(flipMove)
            XCTAssertEqual(underTest.moveStackSize, UInt(1))
            
            // check that the player has been switched
            XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.B)
            
            // check the next state for the move from (1,3) southwest
            if flipMove.startRow == 1 && flipMove.startColumn == 3 && flipMove.direction == JCSHexDirection.SW {
                underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
                    if (row == -1 && column == 0) || (row == -1 && column == 1) || (row == 0 && column == 2) || (row == 1 && column == 3) {
                        XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerA)
                    } else if (row == 0 && column == 1) {
                        XCTAssertEqual(cellState, JCSFlipCellState.OwnedByPlayerB)
                    } else {
                        XCTAssertEqual(cellState, JCSFlipCellState.Empty)
                    }
                    return true
                }
            }
            
            return true
        }
        
        // check that all moves have been considered
        XCTAssertEqual(expectedMoves.count, 0)
        
        // check that move stack is empty again
        XCTAssertEqual(underTest.moveStackSize, UInt(0))
        
        // check that the state is changed back properly
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(cellState, cellStateAtBlock(row, column))
            return true
        }
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.A)
        XCTAssertEqual(underTest.cellCountPlayerA, 2)
        XCTAssertEqual(underTest.cellCountPlayerB, 2)
        XCTAssertEqual(underTest.cellCountEmpty, 44)
    }
    
    func testApplyAllPossibleMovesAndInvokeBlockNoFlipOnlyOnce() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // B-A chain starting at (-1,0) and pointing NW, and B-A chain starting at (1,-3) and pointing SE
            if (row == 0 && column == -1) || (row == 0 && column == -2) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if (row == -1 && column == 0) || (row == 1 && column == -3) {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        
        // the possible moves for A are:
        // start at (0,-2) and move in any direction except NW
        // start at (0,-1) and move in any direction
        // only the keys of this dictionary are used
        var expectedMoves = [
            JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.E):0,
            JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.NE):0,
            JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.W):0,
            JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.SW):0,
            JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.SE):0,
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.E):0,
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.NE):0,
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.NW):0,
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.W):0,
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.SW):0,
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.SE):0
        ]
        
        // check the expected moves
        underTest.applyAllPossibleMovesAndInvokeBlock { (move) -> Bool in
            XCTAssertNotNil(move)
            let flipMove = move as JCSFlipMove
            XCTAssertTrue(expectedMoves.indexForKey(flipMove) != nil)
            expectedMoves.removeValueForKey(flipMove)
            XCTAssertEqual(underTest.moveStackSize, UInt(1))
            return true
        }
        
        // the possible no-flip moves for A are:
        // start at (0,-2) and move SE (target (-1,-1))
        // start at (0,-2) and move NE (target (1,-2))
        // start at (0,-1) and move SW (target (-1,-1))
        // start at (0,-1) and move NW (target (1,-2))
        
        // check that exactly one of the no-flip moves with the same target has been considered
        let noFlip1aRemoved = expectedMoves.indexForKey(JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.SE)) == nil
        let noFlip1bRemoved = expectedMoves.indexForKey(JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.SW)) == nil
        XCTAssertTrue(noFlip1aRemoved ^ noFlip1bRemoved)
        
        let noFlip2aRemoved = expectedMoves.indexForKey(JCSFlipMove(startRow: 0, startColumn: -2, direction: JCSHexDirection.NE)) == nil
        let noFlip2bRemoved = expectedMoves.indexForKey(JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.NW)) == nil
        XCTAssertTrue(noFlip2aRemoved ^ noFlip2bRemoved)
        
        // check that all other moves have been considered
        XCTAssertEqual(expectedMoves.count, 2)
        
        // check that the state is changed back properly
        underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(cellState, cellStateAtBlock(row, column))
            return true
        }
        XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.A)
        XCTAssertEqual(underTest.cellCountPlayerA, 2)
        XCTAssertEqual(underTest.cellCountPlayerB, 2)
        XCTAssertEqual(underTest.cellCountEmpty, 45)
    }
    
    
    func testApplyAllPossibleMovesAndInvokeBlockSkip() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // A at (-1,-1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == -1 || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        
        // check that only skipping is possible for A
        var moveCount = 0
        underTest.applyAllPossibleMovesAndInvokeBlock { (move) -> Bool in
            XCTAssertNotNil(move)
            let flipMove = move as JCSFlipMove
            XCTAssertTrue(flipMove.skip)
            
            // expect exactly one next state
            moveCount++
            XCTAssertTrue(moveCount == 1)
            
            // check that the player has been switched
            XCTAssertEqual(underTest.playerToMove, JCSFlipPlayerSide.B)
            
            // check that cell states of the next state match the original state
            underTest.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
                XCTAssertEqual(cellState, cellStateAtBlock(row, column))
                return true
            }
            
            return true
        }
    }
    
    func testForAllCellsInvolvedInLastMoveInvokeBlockOk(reverse: Bool) {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // push move
        underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.SE))
        
        // check invocations
        var invocation = 0
        underTest.forAllCellsInvolvedInLastMoveReverse(reverse) { (row, column, oldCellState, newCellState) -> Bool in
            switch ++invocation {
            case (reverse ? 4 : 1):
                XCTAssertEqual(row, 1)
                XCTAssertEqual(column, -2)
                XCTAssertEqual(oldCellState, JCSFlipCellState.OwnedByPlayerA)
                XCTAssertEqual(newCellState, JCSFlipCellState.OwnedByPlayerA)
                break
            case (reverse ? 3 : 2):
                XCTAssertEqual(row, 0)
                XCTAssertEqual(column, -1)
                XCTAssertEqual(oldCellState, JCSFlipCellState.OwnedByPlayerB)
                XCTAssertEqual(newCellState, JCSFlipCellState.OwnedByPlayerA)
                break
            case (reverse ? 2 : 3):
                XCTAssertEqual(row, -1)
                XCTAssertEqual(column, 0)
                XCTAssertEqual(oldCellState, JCSFlipCellState.OwnedByPlayerA)
                XCTAssertEqual(newCellState, JCSFlipCellState.OwnedByPlayerB)
                break
            case (reverse ? 1 : 4):
                XCTAssertEqual(row, -2)
                XCTAssertEqual(column, 1)
                XCTAssertEqual(oldCellState, JCSFlipCellState.Empty)
                XCTAssertEqual(newCellState, JCSFlipCellState.OwnedByPlayerA)
                break
            default:
                XCTFail("unexpected invocation")
            }
            return true
        }
        XCTAssertEqual(invocation, 4)
    }
    
    
    func testForAllCellsInvolvedInLastMoveInvokeBlockOk() {
        testForAllCellsInvolvedInLastMoveInvokeBlockOk(false)
    }
    
    func testForAllCellsInvolvedInLastMoveInvokeBlockReverseOk() {
        testForAllCellsInvolvedInLastMoveInvokeBlockOk(true)
    }
    
    func testForAllCellsInvolvedInLastMoveInvokeBlockSkip() {
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A at (-1,-1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == -1 || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // push skip
        XCTAssertTrue(underTest.pushMove(JCSFlipMove()))
        
        // check invocations
        underTest.forAllCellsInvolvedInLastMoveReverse(false) { (_, _, _, _) -> Bool in
            XCTFail("unexpected invocation")
            return false
        }
    }
    
    func testForAllCellsInvolvedInLastMoveInvokeBlockStop() {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // push move
        underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.SE))
        
        // check invocations
        var invocation = 0
        underTest.forAllCellsInvolvedInLastMoveReverse(false) { (row, column, oldCellState, newCellState) -> Bool in
            switch ++invocation {
            case 1:
                XCTAssertEqual(row, 1)
                XCTAssertEqual(column, -2)
                XCTAssertEqual(oldCellState, JCSFlipCellState.OwnedByPlayerA)
                XCTAssertEqual(newCellState, JCSFlipCellState.OwnedByPlayerA)
                break
            case 2:
                XCTAssertEqual(row, 0)
                XCTAssertEqual(column, -1)
                XCTAssertEqual(oldCellState, JCSFlipCellState.OwnedByPlayerB)
                XCTAssertEqual(newCellState, JCSFlipCellState.OwnedByPlayerA)
                // now stop!
                return false
            default:
                XCTFail("unexpected invocation")
            }
            return true
        }
        XCTAssertEqual(invocation, 2)
    }
    
    func testCodingWithSize(size: Int, playerToMove: JCSFlipPlayerSide, cellStateAtBlock: (Int, Int) -> JCSFlipCellState, moves: JCSFlipMove...) {
        let underTest = JCSFlipGameState(size: size, playerToMove: playerToMove, cellStateAtBlock: cellStateAtBlock)
        
        // push given moves
        for move in moves {
            underTest.pushMove(move)
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(underTest)
        
        let reloaded = NSKeyedUnarchiver.unarchiveObjectWithData(data) as JCSFlipGameState
        
        // check properties
        XCTAssertEqual(reloaded.status, underTest.status)
        XCTAssertEqual(reloaded.cellCountPlayerA, underTest.cellCountPlayerA)
        XCTAssertEqual(reloaded.cellCountPlayerB, underTest.cellCountPlayerB)
        XCTAssertEqual(reloaded.cellCountEmpty, underTest.cellCountEmpty)
        XCTAssertEqual(reloaded.zobristHash, underTest.zobristHash)
        XCTAssertEqual(reloaded.moveStackSize, underTest.moveStackSize)
        
        // check cell states and undo moves
        while underTest.moveStackSize > 0 {
            // check cell states (must match original board)
            reloaded.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
                XCTAssertEqual(cellState, underTest.cellStateAtRow(row, column: column))
                return true
            }
            
            reloaded.popMove()
            underTest.popMove()
        }
        
        // check cell states (must be back to initial)
        reloaded.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(cellState, cellStateAtBlock(row, column))
            return true
        }
        
        // check that move stack is empty
        XCTAssertEqual(reloaded.moveStackSize, UInt(0))
    }
    
    func testCoding() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        testCodingWithSize(4, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock, moves:
            JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.E),
            JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.NW),
            JCSFlipMove(startRow: 1, startColumn: -1, direction: JCSHexDirection.W)
        )
    }
    
    func testCodingWithEmptyMoveStack() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        testCodingWithSize(4, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
    }
    
    func testCodingWithLimitedMoveStack() {
        let cellStateAtBlock = { (row: Int, column: Int) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A, cellStateAtBlock: cellStateAtBlock)
        
        // push some moves
        underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.E))
        underTest.pushMove(JCSFlipMove(startRow: 0, startColumn: -1, direction: JCSHexDirection.NW))
        underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -1, direction: JCSHexDirection.W))
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWithMutableData: data)
        underTest.encodeWithCoder(coder, maxMoves: 2)
        coder.finishEncoding()
        
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let reloaded = JCSFlipGameState(coder: decoder)
        
        // check properties
        XCTAssertEqual(reloaded.status, underTest.status)
        XCTAssertEqual(reloaded.cellCountPlayerA, underTest.cellCountPlayerA)
        XCTAssertEqual(reloaded.cellCountPlayerB, underTest.cellCountPlayerB)
        XCTAssertEqual(reloaded.cellCountEmpty, underTest.cellCountEmpty)
        XCTAssertEqual(reloaded.zobristHash, underTest.zobristHash)
        XCTAssertEqual(reloaded.moveStackSize, UInt(2))
        
        // check cell states (must match original board)
        reloaded.forAllCellsInvokeBlock { (row, column, cellState) -> Bool in
            XCTAssertEqual(cellState, underTest.cellStateAtRow(row, column: column))
            return true
        }
        
        // undo the two moves that have been coded
        reloaded.popMove()
        reloaded.popMove()
        
        // check that move stack is empty
        XCTAssertEqual(reloaded.moveStackSize, UInt(0))
    }
    
    func testLastMove() {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        // push/pop some moves and check the last move
        let firstMove = JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.SE)
        let secondMove = JCSFlipMove(startRow: -1, startColumn: 0, direction: JCSHexDirection.W)
        
        XCTAssertNil(underTest.lastMove)
        underTest.pushMove(firstMove)
        XCTAssertEqual(underTest.lastMove, firstMove)
        underTest.pushMove(secondMove)
        XCTAssertEqual(underTest.lastMove, secondMove)
        underTest.popMove()
        XCTAssertEqual(underTest.lastMove, firstMove)
        underTest.popMove()
        XCTAssertNil(underTest.lastMove)
    }
    
    func testLastMoveSkip() {
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            //    A
            // O B
            if row == 1 && column == 0 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == 0 {
                return JCSFlipCellState.OwnedByPlayerB
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.Empty
            } else {
                return JCSFlipCellState.Hole
            }
        }
        
        // push/pop skip move and check the last move
        let skipMove = JCSFlipMove()
        
        XCTAssertNil(underTest.lastMove)
        underTest.pushMove(skipMove)
        XCTAssertEqual(underTest.lastMove, skipMove)
        underTest.popMove()
        XCTAssertNil(underTest.lastMove)
    }
    
    func testZobristHashPushAndPopNormalMove() {
        let underTest = JCSFlipGameState(size: 4, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A-B-A chain starting at (1,-2) and pointing SE
            if (row == 1 && column == -2) || (row == -1 && column == 0) {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == 0 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let zobristBefore = underTest.zobristHash
        underTest.pushMove(JCSFlipMove(startRow: 1, startColumn: -2, direction: JCSHexDirection.SE))
        XCTAssertNotEqual(underTest.zobristHash, zobristBefore)
        underTest.popMove()
        XCTAssertEqual(underTest.zobristHash, zobristBefore)
    }
    
    func testZobristHashPushAndPopSkipMove() {
        let underTest = JCSFlipGameState(size: 2, playerToMove: JCSFlipPlayerSide.A) { (row, column) -> JCSFlipCellState in
            // A at (-1,-1), B at remainder of row -1 and column -1
            if row == -1 && column == -1 {
                return JCSFlipCellState.OwnedByPlayerA
            } else if row == -1 || column == -1 {
                return JCSFlipCellState.OwnedByPlayerB
            } else {
                return JCSFlipCellState.Empty
            }
        }
        
        let zobristBefore = underTest.zobristHash
        underTest.pushMove(JCSFlipMove())
        XCTAssertNotEqual(underTest.zobristHash, zobristBefore)
        underTest.popMove()
        XCTAssertEqual(underTest.zobristHash, zobristBefore)
    }
}
