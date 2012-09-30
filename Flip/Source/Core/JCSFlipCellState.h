//
//  NSObject_JCSFlipCellState.h
//  Flip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

enum {
    JCSFlipCellStateHole = 0,
    JCSFlipCellStateEmpty = 1,
    JCSFlipCellStateOwnedByPlayerA = 2,
    JCSFlipCellStateOwnedByPlayerB = 3,
};
typedef NSInteger JCSFlipCellState;

// determine the cell state matching a game status (JCSFlipGameStatusPlayerAToMove or JCSFlipGameStatusPlayerBToMove)
#define JCSFlipCellStateForGameStatus(status) ((status) == JCSFlipGameStatusPlayerAToMove ? JCSFlipCellStateOwnedByPlayerA : JCSFlipCellStateOwnedByPlayerB)

// determine the "flip" cell state for a cell state (JCSFlipGameStatusPlayerAToMove or JCSFlipGameStatusPlayerBToMove)
#define JCSFlipCellStateOther(cellState) (JCSFlipCellStateOwnedByPlayerA + JCSFlipCellStateOwnedByPlayerB - (cellState))
