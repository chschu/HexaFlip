//
//  JCSFlipUIGameScreen.h
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipMoveInputDelegate.h"
#import "JCSFlipPlayer.h"
#import "JCSFlipUIScreen.h"
#import "JCSFlipUIGameScreenDelegate.h"

#import "cocos2d.h"

@interface JCSFlipUIGameScreen : CCNode <JCSFlipMoveInputDelegate, JCSFlipUIScreen>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIGameScreenDelegate> delegate;

// start a game with the given state and players
// set the receiver as the move input delegate of both players
- (void)startGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB;

@end
