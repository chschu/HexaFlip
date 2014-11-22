//
//  JCSNegamaxGameAlgorithmTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 21.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import XCTest

class JCSNegamaxGameAlgorithmTest : XCTestCase {
    
    let underTest = JCSNegamaxGameAlgorithm(depth: 9, heuristic: TicTacToeHeuristic())
    
    func testAlgorithm() {
        continueAfterFailure = false
        let node = TicTacToeNode()
        while !node.leaf {
            let move = underTest.moveAtNode(node)
            XCTAssertNotNil(move, "move returned by algorithm must not be nil for non-leaf node")
            node.pushMove(move)
            NSLog("\n%@", node.description)
        }
        XCTAssertTrue(node.gameState.draw, "game must end in a draw")
    }
}

// @objc is required to make the algorithm print move descriptions correctly
@objc class TicTacToeMove : JCSMove, Printable {
    
    var value: Float = 0.0
    var row: Int
    var column: Int
    
    var description: String {
        return "(\(row),\(column))"
    }
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
    
    func compareByValueTo(other: JCSMove) -> NSComparisonResult {
        return value < other.value ? .OrderedAscending : value > other.value ? .OrderedDescending : .OrderedSame
    }
}

let p3 = [1, 3, 9, 27, 81, 243, 729, 2187, 6561]

class TicTacToeNode : JCSGameNode, Printable {
    
    enum GameState {
        case Open
        case Won(Player)
        case Draw
        
        var open: Bool {
            switch self {
            case .Open: return true
            default: return false
            }
        }
        
        var won: Bool {
            switch self {
            case .Won(_): return true
            default: return false
            }
        }
        
        var draw: Bool {
            return !open && !won
        }
    }
    
    enum Player : String {
        case X = "X"
        case O = "O"
        
        var other: Player {
            return self == .X ? .O : .X
        }
    }
    
    var gameState = GameState.Open
    var ownerGrid: [[Player?]] = [[nil, nil, nil], [nil, nil, nil], [nil, nil, nil]]
    var emptyCells = 9
    var scoreInRow = [0, 0, 0]
    var scoreInColumn = [0, 0, 0]
    var scoreInDiagonal = [0, 0]
    var playerToMove = Player.X
    var moveStack: [(row: Int, column: Int)] = []
    var zobristHash = UInt(0)
    
    var leaf: Bool {
        return !gameState.open
    }
    
    var description: String {
        var result = ""
        for ownerRow in ownerGrid {
            for owner in ownerRow {
                result += "[" + (owner?.rawValue ?? " ") + "]"
            }
            result += "\n"
        }
        return result
    }
    
    func applyAllPossibleMovesAndInvokeBlock(block: (JCSMove!) -> Bool) {
        if !gameState.open {
            return
        }
        for (var row = 0, keepRunning = true; row < 3 && keepRunning; row++) {
            for (var column = 0; column < 3 && keepRunning; column++) {
                if ownerGrid[row][column] == nil {
                    let move = TicTacToeMove(row: row, column: column)
                    let pushed = pushMove(move)
                    assert(pushed, "pushMove() must be successful")
                    keepRunning &= block(move)
                    popMove()
                }
            }
        }
    }
    
    func pushMove(move: JCSMove) -> Bool {
        if !gameState.open {
            return false
        }
        let tttMove = move as TicTacToeMove
        let row = tttMove.row
        let column = tttMove.column
        if ownerGrid[row][column] != nil {
            return false
        }
        
        ownerGrid[row][column] = playerToMove
        emptyCells--
        var won = false
        var scoreValue = playerToMove == .X ? 1 : -1
        scoreInRow[row] += scoreValue
        won |= scoreInRow[row] == 3*scoreValue
        scoreInColumn[column] += scoreValue
        won |= scoreInColumn[column] == 3*scoreValue
        if row == column {
            scoreInDiagonal[0] += scoreValue
            won |= scoreInDiagonal[0] == 3*scoreValue
        }
        if row+column == 2 {
            scoreInDiagonal[1] += scoreValue
            won |= scoreInDiagonal[1] == 3*scoreValue
        }
        if won {
            gameState = .Won(playerToMove)
        } else if emptyCells == 0 {
            gameState = .Draw
        }
        zobristHash += (playerToMove == .X ? 1 : 2) * p3[3*row+column]
        playerToMove = playerToMove.other
        
        let changeStackEntry = (row: tttMove.row, column: tttMove.column)
        moveStack.append(changeStackEntry)
        
        return true
    }
    
    func popMove() {
        let (row, column) = moveStack.removeLast()
        
        playerToMove = playerToMove.other
        zobristHash -= (playerToMove == .X ? 1 : 2) * p3[3*row+column]
        ownerGrid[row][column] = nil
        emptyCells++
        var scoreValue = playerToMove == .X ? 1 : -1
        scoreInRow[row] -= scoreValue
        scoreInColumn[column] -= scoreValue
        if row == column {
            scoreInDiagonal[0] -= scoreValue
        }
        if row+column == 2 {
            scoreInDiagonal[1] -= scoreValue
        }
        gameState = .Open
    }
}

class TicTacToeHeuristic : JCSGameHeuristic {
    
    func valueOfNode(node: JCSGameNode) -> Float {
        // result is 0 for open game and draw
        // if game is won, result is strictly negative (player to move loses)
        // slower defeat (less empty cells) is considered better
        let tttNode = node as TicTacToeNode
        return tttNode.gameState.won ? -Float(1 + tttNode.emptyCells) : 0
    }
}
