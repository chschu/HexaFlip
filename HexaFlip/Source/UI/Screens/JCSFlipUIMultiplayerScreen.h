//
//  JCSFlipUIMultiplayerScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 15.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipUIScreenWithPoint.h"

#import "cocos2d.h"

@protocol JCSFlipUIMultiplayerScreenDelegate;

@interface JCSFlipUIMultiplayerScreen : CCNode <JCSFlipUIScreenWithPoint, GKTurnBasedMatchmakerViewControllerDelegate>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIMultiplayerScreenDelegate> delegate;

// modally present the controller for matchmaking
- (void)presentMatchMakerViewController;

@end
