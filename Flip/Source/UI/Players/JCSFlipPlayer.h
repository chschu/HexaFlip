//
//  JCSFlipPlayer.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@class JCSFlipGameState;
@protocol JCSFlipPlayerMoveInputDelegate;

@protocol JCSFlipPlayer <NSObject>

// display name of the player
@property (readonly, nonatomic) NSString *name;

// does the player have local controls?
// YES for local human players, NO otherwise
@property (readonly, nonatomic) BOOL localControls;

// the delegate to be used if the player implementation requires automatic move input
@property (weak, nonatomic) id<JCSFlipPlayerMoveInputDelegate> moveInputDelegate;

// notify the player that the opponent has taken a turn
- (void)opponentDidMakeMove:(JCSFlipGameState *)state;

// tell the player it's their turn
- (void)tellMakeMove:(JCSFlipGameState *)state;

@end
