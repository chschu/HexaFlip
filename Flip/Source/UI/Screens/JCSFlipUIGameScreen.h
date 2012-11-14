//
//  JCSFlipUIGameScreen.h
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipPlayerMoveInputDelegate.h"
#import "JCSFlipPlayer.h"
#import "JCSFlipUIScreen.h"
#import "JCSFlipUIGameScreenDelegate.h"

#import "cocos2d.h"

@interface JCSFlipUIGameScreen : CCNode <JCSFlipPlayerMoveInputDelegate, JCSFlipUIScreen>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIGameScreenDelegate> delegate;

// prepare a game with the given state and players
// set the receiver as the move input delegate of both players
- (void)prepareGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB;

// start a previously prepared game
// the screen must be enabled when this method is invoked
- (void)startGame;

@end
