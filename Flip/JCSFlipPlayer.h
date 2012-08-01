//
//  JCSFlipPlayer.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipMoveInputDelegate.h"

@protocol JCSFlipPlayer <NSObject>

// display name of the player
@property (strong, readonly) NSString *name;

// does the player have local controls?
// YES for local human players, NO otherwise
@property (readonly) BOOL localControls;

// tell the player it's their turn
- (void)tellMakeMove:(JCSFlipGameState *)state;

@end
