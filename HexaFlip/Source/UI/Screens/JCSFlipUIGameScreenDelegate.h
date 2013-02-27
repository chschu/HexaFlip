//
//  JCSFlipUIGameScreenDelegate.h
//  HexaFlip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"

@class JCSFlipUIGameScreen;

@protocol JCSFlipUIGameScreenDelegate <NSObject>

// invoked when the game has been exited by using the exit button
- (void)exitGameMultiplayer:(BOOL)multiplayer fromGameScreen:(JCSFlipUIGameScreen *)screen;

@end
