//
//  JCSFlipPlayer.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipPlayerMoveInputDelegate.h"

@protocol JCSFlipPlayer <NSObject>

// display name of the player
@property (readonly, nonatomic) NSString *name;

// does the player have local controls?
// YES for local human players, NO otherwise
@property (readonly, nonatomic) BOOL localControls;

// the delegate to be used if the player implementation requires automatic move input
@property (weak, nonatomic) id<JCSFlipPlayerMoveInputDelegate> moveInputDelegate;

// tell the player it's their turn
- (void)tellMakeMove:(JCSFlipGameState *)state;

@end
