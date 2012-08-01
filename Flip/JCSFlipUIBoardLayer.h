//
//  JCSFlipUIBoardLayer.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"
#import "JCSFlipCellState.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMoveInputDelegate.h"

#import "cocos2d.h"

// the layer displaying the current board
@interface JCSFlipUIBoardLayer : CCNode <JCSFlipMoveInputDelegate>

// the delegate for forward input information to
@property (weak, nonatomic) id<JCSFlipMoveInputDelegate> inputDelegate;

// is local move input enabled (NO by default)
@property (nonatomic) BOOL moveInputEnabled;

// initializes the view with the given game state
- (id)initWithState:(JCSFlipGameState *)state;

// asynchronously start an animation for the given move
// after the animation is done, the block is invoked (asnychronously!)
- (void)animateMove:(JCSFlipMove *)move newGameState:(JCSFlipGameState *)newGameState afterAnimationInvokeBlock:(void(^)())block;

@end
