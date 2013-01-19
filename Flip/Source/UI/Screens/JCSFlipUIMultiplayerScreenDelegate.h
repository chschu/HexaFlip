//
//  JCSFlipUIMultiplayerScreenDelegate.h
//  Flip
//
//  Created by Christian Schuster on 15.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

@class JCSFlipUIMultiplayerScreen;
@class JCSFlipGameState;

@protocol JCSFlipPlayer;

@protocol JCSFlipUIMultiplayerScreenDelegate <NSObject>

// match-making has been cancelled
- (void)matchMakingCancelledFromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

// match-making has failed
- (void)matchMakingFailedWithError:(NSError *)error fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

// match-making succeeded - switch to game
- (void)switchToGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB gameState:(JCSFlipGameState *)gameState fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

@end
