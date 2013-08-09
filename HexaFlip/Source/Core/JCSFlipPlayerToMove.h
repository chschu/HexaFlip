//
//  JCSFlipPlayerToMove.h
//  HexaFlip
//
//  Created by Christian Schuster on 23.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

typedef enum {
	JCSFlipPlayerToMoveA = 0,
	JCSFlipPlayerToMoveB = 1,
} JCSFlipPlayerToMove;

#define JCSFlipPlayerToMoveOther(playerToMove) (JCSFlipPlayerToMoveA + JCSFlipPlayerToMoveB - (playerToMove))
