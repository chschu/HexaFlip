//
//  JCSFlipUIMultiplayerScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 15.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipUIBaseScreen.h"

#import "cocos2d.h"

@protocol JCSFlipUIMultiplayerScreenDelegate;

@interface JCSFlipUIMultiplayerScreen : JCSFlipUIBaseScreen <GKTurnBasedMatchmakerViewControllerDelegate>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIMultiplayerScreenDelegate> delegate;

// the players to invite (when triggered from the game center app), or nil
@property (nonatomic) NSArray *playersToInvite;

@end
