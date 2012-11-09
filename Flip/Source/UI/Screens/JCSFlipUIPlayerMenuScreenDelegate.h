//
//  JCSFlipUIPlayerMenuScreenDelegate.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"

// protocol for actions triggered by the player selection menu screen
@protocol JCSFlipUIPlayerMenuScreenDelegate <NSObject>

// start a game using the given players
- (void)startGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB;

// "Back" button has been tapped
- (void)backFromPlayerMenuScreen;

@end
