//
//  JCSFlipGameState.h
//  HexaFlip
//
//  Created by Christian Schuster on 25.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef enum {
	JCSFlipGameStatusPlayerAToMove = 0,
	JCSFlipGameStatusPlayerBToMove = 1,
	JCSFlipGameStatusPlayerAWon = 2,
	JCSFlipGameStatusPlayerBWon = 3,
	JCSFlipGameStatusDraw = 4,
} JCSFlipGameStatus;

#define JCSFlipGameStatusOtherPlayerToMove(status) (JCSFlipGameStatusPlayerAToMove + JCSFlipGameStatusPlayerBToMove - (status))
