//
//  JCSFlipUIGameScene.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIGameScene.h"
#import "JCSFlipUIBoardLayer.h"
#import "JCSFlipCellState.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"
#import "JCSFlipUIBackgroundLayer.h"
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSRandomGameAlgorithm.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameStatePossessionSafetyHeuristic.h"

@implementation JCSFlipUIGameScene {
    JCSFlipGameState *_state;

    JCSFlipUIBoardLayer *_boardLayer;

    CCMenuItemFont *_skipButton;
}

@synthesize playerA = _playerA;
@synthesize playerB = _playerB;

- (id)initWithState:(JCSFlipGameState *)state {
    if (self = [super init]) {
        _state = [state copy];
    }
    return self;
}

- (void)onEnter {
    [super onEnter];
    
    // both players must have been set
    NSAssert(_playerA != nil, @"playerA must be non-nil when the game scene enters the stage");
    NSAssert(_playerB != nil, @"playerB must be non-nil when the game scene enters the stage");
    
    _boardLayer = [[JCSFlipUIBoardLayer alloc] initWithState:_state];
    _boardLayer.inputDelegate = self;
    
    JCSFlipUIBackgroundLayer *backgroundLayer = [[JCSFlipUIBackgroundLayer alloc] init];
    
    [self addChild:_boardLayer z:0];
    [self addChild:backgroundLayer z:-10];
    
    CCDirector *director = [CCDirector sharedDirector];
    
    NSInteger windowWidth = director.winSize.width;
    NSInteger windowHeight = director.winSize.height;
    
    _skipButton = [CCMenuItemFont itemWithString:@"skip" block:^(id sender) {
        [self inputConfirmedWithMove:[JCSFlipMove moveSkip]];
    }];
    _skipButton.color = ccc3(0, 0, 0);
    _skipButton.position = ccp(-(windowWidth/2-_skipButton.boundingBox.size.width), -(windowHeight/2-_skipButton.boundingBox.size.height));
    
    CCMenu *menu = [CCMenu menuWithItems:_skipButton, nil];
    [self addChild:menu];
    
    // center board layer' origin on screen, and scale properly
    // TODO: determine scale programmatically
    _boardLayer.position = ccp(windowWidth/2, windowHeight/2);
    _boardLayer.scale = 96 * 0.5;
    
    [self enableUIAndNotifyPlayer];
}

- (void)disableMoveInput {
    _boardLayer.moveInputEnabled = NO;
    _skipButton.visible = NO;
}

// prepare the UI for a player's move input
- (void)enableUIAndNotifyPlayer {
    // A enabled iff player A to move, and player A does not block input
    BOOL playerAEnabled = (_state.status == JCSFlipGameStatusPlayerAToMove && _playerA.localControls);
    BOOL playerBEnabled = (_state.status == JCSFlipGameStatusPlayerBToMove && _playerB.localControls);
 
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = playerAEnabled || playerBEnabled;
    _skipButton.visible = _state.skipAllowed && (playerAEnabled || playerBEnabled);
    
    // determine current player
    id<JCSFlipPlayer> currentPlayer = nil;
    if (_state.status == JCSFlipGameStatusPlayerAToMove) {
        currentPlayer = _playerA;
    } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
        currentPlayer = _playerB;
    }

    // tell the current player to make a move
    [currentPlayer tellMakeMove:_state];
}

- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    if ([_state cellStateAtRow:startRow column:startColumn] == JCSFlipCellStateForGameStatus(_state.status)) {
        // TODO: visual
        return YES;
    }
    return NO;
}

- (void)inputSelectedDirection:(JCSHexDirection)direction {
    // TODO: visual
}

- (BOOL)inputConfirmedWithMove:(JCSFlipMove *)move {
    // apply the move to a temporary copy
    if ([_state applyMove:move]) {
        NSLog(@"confirmed move %@", move);
        // block move input during animation
        [self disableMoveInput];
        [_boardLayer animateMove:move newGameState:_state afterAnimationInvokeBlock:^{
            // animation is done - update UI and notify player
            [self enableUIAndNotifyPlayer];
        }];
        return YES;
    }
    return NO;
}

- (void)inputCancelled {
    // TODO: visual
}

- (void)setPlayerA:(id<JCSFlipPlayer>)playerA {
    NSAssert(!self.isRunning, @"playerA may not be set if the scene is running");
    _playerA = playerA;
}

- (void)setPlayerB:(id<JCSFlipPlayer>)playerB {
    NSAssert(!self.isRunning, @"playerB may not be set if the scene is running");
    _playerB = playerB;
}

@end
