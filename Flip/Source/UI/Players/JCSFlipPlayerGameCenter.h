//
//  JCSFlipPlayerGameCenter.h
//  Flip
//
//  Created by Christian Schuster on 12.12.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipPlayer.h"

@interface JCSFlipPlayerGameCenter : NSObject <JCSFlipPlayer, GKMatchmakerViewControllerDelegate>

// create an auto-matched Game Center player
+ (id)player;

@end
