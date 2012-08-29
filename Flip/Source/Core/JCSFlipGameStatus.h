//
//  JCSFlipGameState.h
//  Flip
//
//  Created by Christian Schuster on 25.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef enum {
	JCSFlipGameStatusPlayerAToMove,
	JCSFlipGameStatusPlayerBToMove,
	JCSFlipGameStatusPlayerAWon,
	JCSFlipGameStatusPlayerBWon,
	JCSFlipGameStatusDraw,
} JCSFlipGameStatus;

#define JCSFlipGameStatusOtherPlayerToMove(status) (JCSFlipGameStatusPlayerAToMove + JCSFlipGameStatusPlayerBToMove - (status))
