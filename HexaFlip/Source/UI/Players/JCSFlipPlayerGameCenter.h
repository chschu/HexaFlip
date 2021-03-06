//
//  JCSFlipPlayerGameCenter.h
//  HexaFlip
//
//  Created by Christian Schuster on 12.12.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"

@interface JCSFlipPlayerGameCenter : NSObject <JCSFlipPlayer>

// create a player interacting with game center
+ (id)player;

@end
