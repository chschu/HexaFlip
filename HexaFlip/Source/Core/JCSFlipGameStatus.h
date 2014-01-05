//
//  JCSFlipGameState.h
//  HexaFlip
//
//  Created by Christian Schuster on 25.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef NS_ENUM(NSInteger, JCSFlipGameStatus) {
	JCSFlipGameStatusOpen = 0,
	JCSFlipGameStatusPlayerAWon = 1,
	JCSFlipGameStatusPlayerBWon = 2,
	JCSFlipGameStatusDraw = 3,
};

#define JCSFlipGameStatusIsOver(status) ((status) != JCSFlipGameStatusOpen)