//
//  JCSGameAlgorithmTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 27.09.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import XCTest


class JCSGameAlgorithmTest : XCTestCase {
    
    func testNegamax2VsNegamax1() {
        let paranoid = JCSFlipGameStatePSRHeuristic(possession: 1, safety: 3, randomness: 0)
        let algoA = JCSNegamaxGameAlgorithm(depth: 2, heuristic: paranoid)
        let algoB = JCSNegamaxGameAlgorithm(depth: 1, heuristic: paranoid)
        testAlgorithm(algoA, algoB, boardSize: 4)
    }
    
    func testNegamax3VsNegamax2() {
        let careless = JCSFlipGameStatePSRHeuristic(possession: 1, safety: 0, randomness: 2)
        let paranoid = JCSFlipGameStatePSRHeuristic(possession: 1, safety: 3, randomness: 0)
        let algoA = JCSNegamaxGameAlgorithm(depth: 3, heuristic: careless)
        let algoB = JCSNegamaxGameAlgorithm(depth: 2, heuristic: paranoid)
        testAlgorithm(algoA, algoB, boardSize: 4)
    }
    
    func testNegamax3VsRandom() {
        let safe = JCSFlipGameStatePSRHeuristic(possession: 1, safety: 0.5, randomness: 0.25)
        let algoA = JCSNegamaxGameAlgorithm(depth: 3, heuristic: safe)
        let algoB = JCSRandomGameAlgorithm(seed: 9391829)
        testAlgorithm(algoA, algoB, boardSize: 4)
    }
    
    func testNegaScoutVsNegaScout() {
        let possessive = JCSFlipGameStatePossessionHeuristic()
        let algoAB = JCSNegaScoutGameAlgorithm(depth: 5, heuristic: possessive)
        testAlgorithm(algoAB, algoAB, boardSize: 4)
    }
    
    func testAlgorithm(algoA: JCSGameAlgorithm, _ algoB: JCSGameAlgorithm, boardSize: Int) {
        let state = JCSFlipGameState(size: boardSize, playerToMove: JCSFlipPlayerSide.A)
        while !state.leaf {
            let algo = (state.playerToMove == JCSFlipPlayerSide.A ? algoA : algoB)
            let move: AnyObject! = algo.moveAtNode(state)
            XCTAssertNotNil(move, "move returned by algorithm must not be nil for non-leaf node")
            state.pushMove(move)
            NSLog("\n%@", state)
        }
        NSLog("done, final scores %d:%d", state.cellCountPlayerA, state.cellCountPlayerB)
        XCTAssertTrue(state.status == JCSFlipGameStatus.PlayerAWon || state.status == JCSFlipGameStatus.PlayerBWon || state.status == JCSFlipGameStatus.Draw)
    }
}