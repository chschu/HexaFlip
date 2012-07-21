//
//  NSObject_JCSFlipCellState.h
//  Flip
//
//  Created by Christian Schuster on 19.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef enum {
    JCSFlipCellStateHole,
    JCSFlipCellStateEmpty,
    JCSFlipCellStateOwnedByPlayerA,
    JCSFlipCellStateOwnedByPlayerB,
} JCSFlipCellState;

#define JCSFlipCellStateForPlayer(player) ((player) == JCSFlipPlayerA ? JCSFlipCellStateOwnedByPlayerA : JCSFlipCellStateOwnedByPlayerB)

#define JCSFlipCellStateOther(cellState) (JCSFlipCellStateOwnedByPlayerA + JCSFlipCellStateOwnedByPlayerB - (cellState))
