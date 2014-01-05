//
//  JCSFlipPlayerSide.h
//  HexaFlip
//
//  Created by Christian Schuster on 23.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

typedef NS_ENUM(NSInteger, JCSFlipPlayerSide) {
	JCSFlipPlayerSideA = 0,
	JCSFlipPlayerSideB = 1,
};

#define JCSFlipPlayerSideOther(playerSide) (JCSFlipPlayerSideA + JCSFlipPlayerSideB - (playerSide))
