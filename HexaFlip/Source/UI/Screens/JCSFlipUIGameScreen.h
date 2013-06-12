//
//  JCSFlipUIGameScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipMoveInputDelegate.h"
#import "JCSFlipUIScreenWithPoint.h"
#import "JCSFlipUIBaseScreen.h"

#import "cocos2d.h"

@class JCSFlipGameState;
@protocol JCSFlipPlayer;
@protocol JCSFlipUIGameScreenDelegate;

@interface JCSFlipUIGameScreen : JCSFlipUIBaseScreen <JCSFlipUIScreenWithPoint, JCSFlipMoveInputDelegate>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIGameScreenDelegate> delegate;

// prepare a game with the given state, players, and game center match
// set the receiver as the move input delegate of both players
// the players might be both nil to show a read-only game
// the match might be nil for local games
// if animateLastMove is set to YES, the last move of the game state is replayed when the game is started
// if moveInputDisabled is set to YES, move input will be disabled completely
- (void)prepareGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled;

// start a previously prepared game
// the screen must be enabled when this method is invoked
- (void)startGame;

@end
