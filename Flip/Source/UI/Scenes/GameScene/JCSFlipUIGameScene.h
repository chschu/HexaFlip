//
//  JCSFlipUIGameScene.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMoveInputDelegate.h"
#import "JCSFlipGameState.h"
#import "JCSFlipPlayer.h"

#import "cocos2d.h"

// the game scene
@interface JCSFlipUIGameScene : CCScene <JCSFlipMoveInputDelegate>

// initialize with a game state (which is copied) and two players
// the scene is registered as the move input delegate of both players
+ (id)nodeWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB exitBlock:(void(^)(id))exitBlock;

@end
