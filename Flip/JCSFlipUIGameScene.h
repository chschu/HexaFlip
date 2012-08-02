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

// first player
// must be non-nil when the scene enters stage (- onEnter)
// must not be changed while the scene is "on stage"
@property (strong, nonatomic) id<JCSFlipPlayer> playerA;

// first player
// must be non-nil when the scene enters stage (- onEnter)
// must not be changed while the scene is "on stage"
@property (strong, nonatomic) id<JCSFlipPlayer> playerB;

// initialize with a game state (which is copied)
// players must be set on the result, before the scene enters stage (- onEnter)
+ (JCSFlipUIGameScene *)sceneWithState:(JCSFlipGameState *)state;

@end
