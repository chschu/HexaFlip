//
//  JCSFlipUIPlayerMenuScreenDelegate.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@class JCSFlipUIPlayerMenuScreen;
@protocol JCSFlipPlayer;

// protocol for actions triggered by the player selection menu screen
@protocol JCSFlipUIPlayerMenuScreenDelegate <NSObject>

// start a game using the given players
- (void)startGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB fromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen;

// "Back" button has been tapped
- (void)backFromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen;

@end
