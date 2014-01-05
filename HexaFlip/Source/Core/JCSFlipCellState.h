//
//  JCSFlipCellState.h
//  HexaFlip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// define as single-byte type for easier serialization
typedef NS_ENUM(uint8_t, JCSFlipCellState) {
    JCSFlipCellStateHole = 0,
    JCSFlipCellStateEmpty = 1,
    JCSFlipCellStateOwnedByPlayerA = 2,
    JCSFlipCellStateOwnedByPlayerB = 3,
};

// determine the cell state matching a player side
#define JCSFlipCellStateForPlayerSide(playerSide) ((playerSide) == JCSFlipPlayerSideA ? JCSFlipCellStateOwnedByPlayerA : JCSFlipCellStateOwnedByPlayerB)

// determine the "flip" cell state for a cell state (JCSFlipGameStatusPlayerAToMove or JCSFlipGameStatusPlayerBToMove)
#define JCSFlipCellStateOther(cellState) (JCSFlipCellStateOwnedByPlayerA + JCSFlipCellStateOwnedByPlayerB - (cellState))
