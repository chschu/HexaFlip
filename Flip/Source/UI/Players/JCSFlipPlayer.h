//
//  JCSFlipPlayer.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@class JCSFlipGameState;
@protocol JCSFlipMoveInputDelegate;

@protocol JCSFlipPlayer <NSObject>

// display name of the player
@property (readonly, nonatomic) NSString *name;

// does the player have local controls?
// YES for local human players, NO otherwise
@property (readonly, nonatomic) BOOL localControls;

// the delegate to be used if the player implementation requires automatic move input
@property (weak, nonatomic) id<JCSFlipMoveInputDelegate> moveInputDelegate;

// notify the player that the opponent has taken a turn
// used by the game center player to end the turn of the local opponent
- (void)opponentDidMakeMove:(JCSFlipGameState *)state;

// tell the player it's their turn
// initiates automatic move input for AI players
- (void)tellMakeMove:(JCSFlipGameState *)state;

@end
