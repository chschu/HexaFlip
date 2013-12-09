//
//  JCSFlipUIMultiplayerScreenDelegate.h
//  HexaFlip
//
//  Created by Christian Schuster on 15.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

@class JCSFlipUIMultiplayerScreen;
@class JCSFlipGameState;

@protocol JCSFlipPlayer;

@protocol JCSFlipUIMultiplayerScreenDelegate <NSObject>

// match-making has been cancelled
- (void)matchMakingCancelledFromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

// match-making has failed
- (void)matchMakingFailedWithError:(NSError *)error fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

// match-making succeeded - prepare game (but don't start it yet)
// can be used to initialize the board while it is not yet visible
- (void)prepareGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB gameState:(JCSFlipGameState *)gameState match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

// start the previously prepared game
// can be used to start the game when the board has become visible
- (void)startPreparedGameFromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen;

@end
