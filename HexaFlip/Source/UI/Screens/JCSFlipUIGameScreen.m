//
//  JCSFlipUIGameScreen.m
//  HexaFlip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIGameScreen.h"
#import "JCSFlipUIBoardLayer.h"
#import "JCSButton.h"
#import "JCSFlipScoreIndicator.h"
#import "JCSFlipPlayer.h"
#import "JCSFlipUIGameScreenDelegate.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameCenterManager.h"

@implementation JCSFlipUIGameScreen {
    JCSFlipGameState *_state;
    id<JCSFlipPlayer> _playerA;
    id<JCSFlipPlayer> _playerB;
    GKTurnBasedMatch *_match;

    // the last move, to be animated on game start (may be nil)
    JCSFlipMove *_lastMove;

    JCSFlipUIBoardLayer *_boardLayer;
    CCMenuItem *_skipItem;
    JCSFlipScoreIndicator *_scoreIndicator;
}

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // create the exit button
        CCMenuItem *exitItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"stop" block:^(id sender) {
            [_delegate exitFromGameScreen:self];
        }];
        exitItem.anchorPoint = ccp(0,1);
        exitItem.position = ccp(-winSize.width/2+10, winSize.height/2-10);
        
        // create the skip button
        _skipItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"skip" block:^(id sender) {
            if (_screenEnabled) {
                [self inputConfirmedWithMove:[JCSFlipMove moveSkip]];
            }
        }];
        _skipItem.anchorPoint = ccp(0,0);
        _skipItem.position = ccp(-winSize.width/2+10, -winSize.height/2+10);
        
        CCMenu *menu = [CCMenu menuWithItems:exitItem, _skipItem, nil];
        [self addChild:menu z:1];
        
        _scoreIndicator = [JCSFlipScoreIndicator node];
        _scoreIndicator.anchorPoint = ccp(0.5,0.5);
        _scoreIndicator.position = ccp(10+JCSButtonSizeSmall/2.0,winSize.height/2.0);
        [self addChild:_scoreIndicator z:2];
        
        // prepare a "dummy" game to initialize the board and UI state
        [self prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:nil playerB:nil match:nil animateLastMove:NO];
    }
    return self;
}

- (void)prepareGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove {
    NSAssert(state != nil, @"state must not be nil");
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // remove old board
    [_boardLayer removeFromParentAndCleanup:YES];

    _state = state;
    if (animateLastMove) {
        // pop last move if present (will be animated it in -startGame)
        _lastMove = _state.lastMove;
        if (_lastMove != nil) {
            [_state popMove];
        }
    }

    // create new board, and center it vertically on the right border
    _boardLayer = [JCSFlipUIBoardLayer nodeWithState:_state];
    _boardLayer.anchorPoint = ccp(1,0);
    _boardLayer.position = ccp(winSize.width,winSize.height/2);
    [self addChild:_boardLayer z:3];
    
    // assign players (but don't notify yet)
    _playerA = playerA;
    _playerB = playerB;
    
    // assign match
    _match = match;

    // update UI
    [self updateScoreIndicatorAnimated:NO];
    [self enableMoveInput];
}

// notify current player that opponent did make a move
- (void)tellPlayerOpponentDidMakeMove {
    if (_state.playerToMove == JCSFlipPlayerToMoveA) {
        [_playerA opponentDidMakeMove:_state];
    } else {
        [_playerB opponentDidMakeMove:_state];
    }
}

// notify current player to make his move, unless game is over
- (void)tellPlayerMakeMove {
    if (!JCSFlipGameStatusIsOver(_state.status)) {
        if (_state.playerToMove == JCSFlipPlayerToMoveA) {
            [_playerA tellMakeMove:_state];
        } else {
            [_playerB tellMakeMove:_state];
        }
    }
}

- (void)startGame {
    NSAssert(_screenEnabled, @"screen must be enabled");
    if (_lastMove != nil) {
        // apply the move, but don't tell the opponent that the move has been made ("replay")
        BOOL success = [self applyMove:_lastMove replay:YES];
        NSAssert(success, @"unable to apply last move");
        _lastMove = nil;
    } else {
        [self tellPlayerMakeMove];
    }
}

- (void)setScreenEnabled:(BOOL)screenEnabled {
    _screenEnabled = screenEnabled;
    JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
    if (_screenEnabled) {
        // enable automatic move input by players (e.g. for AI players)
        _playerA.moveInputDelegate = self;
        _playerB.moveInputDelegate = self;
        
        // connect to game center event handler
        gameCenterManager.moveInputDelegate = self;
        gameCenterManager.currentMatch = _match;
        
        // connect to board layer for move input
        _boardLayer.inputDelegate = self;
    } else {
        // disable automatic move input by players
        _playerA.moveInputDelegate = nil;
        _playerB.moveInputDelegate = nil;
        
        // disconnect from game center event handler
        gameCenterManager.currentMatch = nil;
        gameCenterManager.moveInputDelegate = nil;
        
        // disconnect from board layer
        _boardLayer.inputDelegate = nil;
    }
}

// disable move input completely
- (void)disableMoveInput {
    _boardLayer.moveInputEnabled = NO;
    _skipItem.isEnabled = NO;
}

// enable move input according to the current game state
- (void)enableMoveInput {
    BOOL gameOver = JCSFlipGameStatusIsOver(_state.status);
    BOOL playerAEnabled = (!gameOver && _state.playerToMove == JCSFlipPlayerToMoveA && _playerA.localControls);
    BOOL playerBEnabled = (!gameOver && _state.playerToMove == JCSFlipPlayerToMoveB && _playerB.localControls);
    
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = playerAEnabled || playerBEnabled;
    _skipItem.isEnabled = _state.skipAllowed && (playerAEnabled || playerBEnabled);
}

- (void)updateScoreIndicatorAnimated:(BOOL)animated {
    [_scoreIndicator setScoreA:_state.cellCountPlayerA scoreB:_state.cellCountPlayerB animated:animated];
}

// pushes the given move to the current game state, animates the move, updates the UI, and notifies the opponent
// replay can be set to YES to "replay" a move, i.e. to not inform the opponent that a move has been made
// the opponent is notified to take his turn afterward (unless the game is over), regardless of "replay"
// returns YES if the game has been applied successfully
- (BOOL)applyMove:(JCSFlipMove *)move replay:(BOOL)replay {
    // push the move to the game state
    BOOL success = [_state pushMove:move];
    if (success) {
        // block move input during animation
        [self disableMoveInput];
        // update score indicator while animating the move
        [self updateScoreIndicatorAnimated:YES];
        [_boardLayer animateLastMoveOfGameState:_state afterAnimationInvokeBlock:^{
            // enable move input
            [self enableMoveInput];
            
            // notify opponent (new current player)
            if (!replay) {
                [self tellPlayerOpponentDidMakeMove];
            }
            [self tellPlayerMakeMove];
        }];
    }
    return success;
}

- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: selected start cell (%d,%d)", startRow, startColumn);
    if ([_state cellStateAtRow:startRow column:startColumn] == JCSFlipCellStateForPlayerToMove(_state.playerToMove)) {
        [_boardLayer startFlashForCellAtRow:startRow column:startColumn];
        return YES;
    }
    return NO;
}

- (void)inputClearedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: cleared start cell");
    [_boardLayer stopFlashForCellAtRow:startRow column:startColumn];
}

- (void)inputSelectedDirection:(JCSHexDirection)direction startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: selected direction %d", direction);
    
    // check if the move is valid
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:startRow startColumn:startColumn direction:direction];
    if ([_state pushMove:move]) {
        // flash all cells involved in the move
        // this also re-triggers the flash of the start cell to get it in sync
        [_state forAllCellsInvolvedInLastMoveInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop) {
            [_boardLayer startFlashForCellAtRow:row column:column];
        }];
        // un-apply the move
        [_state popMove];
    }
}

- (void)inputClearedDirection:(JCSHexDirection)direction startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: cleared direction");
    
    // check if the move is valid
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:startRow startColumn:startColumn direction:direction];
    if ([_state pushMove:move]) {
        // un-flash all cells changed by the move, except the start cell
        [_state forAllCellsInvolvedInLastMoveInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop) {
            if (row != startRow || column != startColumn) {
                [_boardLayer stopFlashForCellAtRow:row column:column];
            }
        }];
        // un-apply the move
        [_state popMove];
    }
}

- (void)inputCancelled {
    NSLog(@"input: cancelled");
}

- (void)inputConfirmedWithMove:(JCSFlipMove *)move {
    NSLog(@"input: confirmed move %@", move);
    
    // apply the move and update UI
    [self applyMove:move replay:NO];
}

@end
