//
//  JCSFlipUIOutcomeScreen.h
//  Flip
//
//  Created by Christian Schuster on 13.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScreen.h"
#import "JCSFlipUIOutcomeScreenDelegate.h"
#import "JCSFlipGameStatus.h"

#import "cocos2d.h"

@interface JCSFlipUIOutcomeScreen : CCNode <JCSFlipUIScreen>

// the game status to display
// this property may only be set to JCSFlipGameStatusPlayerAWon, JCSFlipGameStatusPlayerBWon, or JCSFlipGameStatusDraw
@property (nonatomic) JCSFlipGameStatus status;

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIOutcomeScreenDelegate> delegate;


@end
