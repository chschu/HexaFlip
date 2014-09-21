//
//  JCSFlipGameStatePossessionHeuristicTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 01.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import XCTest

class JCSFlipGameStatePossessionHeuristicTest : XCTestCase {
    
    let underTest = JCSFlipGameStatePossessionHeuristic()
    
    func testValueIsDifferenceWhenPlayerAToMove() {
        let gameStateMock = JCSFlipGameStateMock(status: JCSFlipGameStatus.Open, playerToMove: JCSFlipPlayerSide.A, cellCountPlayerA: 13, cellCountPlayerB: 17)
        XCTAssertEqual(-4.0, underTest.valueOfNode(gameStateMock), "heuristic value must be difference of cell counts")
    }
    
    func testValueIsNegativeDifferenceWhenPlayerBToMove() {
        let gameStateMock = JCSFlipGameStateMock(status: JCSFlipGameStatus.Open, playerToMove: JCSFlipPlayerSide.B, cellCountPlayerA: 4, cellCountPlayerB: 12)
        XCTAssertEqual(+8.0, underTest.valueOfNode(gameStateMock), "heuristic value must be negative difference of cell counts")
    }
    
    func testValueIsNegativeHugeWhenCurrentPlayerLost() {
        let gameStateMock = JCSFlipGameStateMock(status: JCSFlipGameStatus.PlayerBWon, playerToMove: JCSFlipPlayerSide.A, cellCountPlayerA: 4, cellCountPlayerB: 10)
        XCTAssertTrue(underTest.valueOfNode(gameStateMock) < -1e6, "heuristic value must be negative huge")
    }
    
    func testValueIsNegativeInfinityWhenCurrentPlayerWithoutCells() {
        let gameStateMock = JCSFlipGameStateMock(status: JCSFlipGameStatus.PlayerAWon, playerToMove: JCSFlipPlayerSide.B, cellCountPlayerA: 4, cellCountPlayerB: 0)
        XCTAssertEqual(-Float.infinity, underTest.valueOfNode(gameStateMock), "heuristic value must be negative infinity")
    }
    
    func testValueIsPositiveHugeWhenCurrentPlayerLost() {
        let gameStateMock = JCSFlipGameStateMock(status: JCSFlipGameStatus.PlayerAWon, playerToMove: JCSFlipPlayerSide.A, cellCountPlayerA: 13, cellCountPlayerB: 11)
        XCTAssertTrue(underTest.valueOfNode(gameStateMock) > 1e6, "heuristic value must be positive huge")
    }
    
    func testValueIsPositiveInfinityWhenOtherPlayerWithoutCells() {
        let gameStateMock = JCSFlipGameStateMock(status: JCSFlipGameStatus.PlayerBWon, playerToMove: JCSFlipPlayerSide.B, cellCountPlayerA: 0, cellCountPlayerB: 10)
        XCTAssertEqual(Float.infinity, underTest.valueOfNode(gameStateMock), "heuristic value must be positive infinity")
    }
    
    func testHugeValueOnGameOverConsidersCellDifference() {
        let gameStateMock1 = JCSFlipGameStateMock(status: JCSFlipGameStatus.PlayerAWon, playerToMove: JCSFlipPlayerSide.A, cellCountPlayerA: 10, cellCountPlayerB: 7)
        let gameStateMock2 = JCSFlipGameStateMock(status: JCSFlipGameStatus.PlayerAWon, playerToMove: JCSFlipPlayerSide.A, cellCountPlayerA: 10, cellCountPlayerB: 8)
        XCTAssertTrue(underTest.valueOfNode(gameStateMock1) > underTest.valueOfNode(gameStateMock2), "heuristic value must be larger for larger cell difference");
    }
    
    class JCSFlipGameStateMock : JCSFlipGameState {
        
        @objc override var status: JCSFlipGameStatus {
            return mockStatus
        }
        @objc override var playerToMove: JCSFlipPlayerSide {
            return mockPlayerToMove
        }
        @objc override var cellCountPlayerA: Int {
            return mockCellCountPlayerA
        }
        @objc override var cellCountPlayerB: Int {
            return mockCellCountPlayerB
        }
        
        let mockStatus: JCSFlipGameStatus
        let mockPlayerToMove: JCSFlipPlayerSide
        let mockCellCountPlayerA: Int
        let mockCellCountPlayerB: Int
        
        init(status: JCSFlipGameStatus, playerToMove: JCSFlipPlayerSide, cellCountPlayerA: Int, cellCountPlayerB: Int) {
            self.mockStatus = status
            self.mockPlayerToMove = playerToMove
            self.mockCellCountPlayerA = cellCountPlayerA
            self.mockCellCountPlayerB = cellCountPlayerB
            super.init()
        }
        
        required init(coder aDecoder: NSCoder) {
            self.mockStatus = JCSFlipGameStatus.Open
            self.mockPlayerToMove = JCSFlipPlayerSide.A
            self.mockCellCountPlayerA = 0
            self.mockCellCountPlayerB = 0
            super.init(coder: aDecoder)
        }
    }
}