//
//  JCSFlipUIGameScreenDelegate.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"

@class JCSFlipUIGameScreen;

@protocol JCSFlipUIGameScreenDelegate <NSObject>

// invoked when the game has ended
// status is one of JCSFlipGameStatusPlayerAWon, JCSFlipGameStatusPlayerBWon, or JCSFlipGameStatusDraw
- (void)gameEndedWithStatus:(JCSFlipGameStatus)status fromGameScreen:(JCSFlipUIGameScreen *)screen;

// invoked when the game has been exited, without a clear status
- (void)gameEndedFromGameScreen:(JCSFlipUIGameScreen *)screen;

@end
