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
    NSString *_matchID;
    
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
        [self prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:nil playerB:nil matchID:nil];
    }
    return self;
}

- (void)prepareGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB matchID:(NSString *)matchID {
    NSAssert(state != nil, @"state must not be nil");

    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // remove old board
    [_boardLayer removeFromParentAndCleanup:YES];
    
    // create new board, and center it vertically on the right border
    _state = state;
    _boardLayer = [JCSFlipUIBoardLayer nodeWithState:_state];
    _boardLayer.anchorPoint = ccp(1,0);
    _boardLayer.position = ccp(winSize.width,winSize.height/2);
    [self addChild:_boardLayer z:3];

    // assign players (but don't notify yet)
    _playerA = playerA;
    _playerB = playerB;
    
    // assign matchID
    _matchID = matchID;
    
    // update UI
    [self updateScoreIndicatorAnimated:NO];
    [self updateUI];
}

- (void)startGame {
    NSAssert(_screenEnabled, @"screen must be enabled");

    [self updateUI];

    // notify next player
    if (_state.status == JCSFlipGameStatusPlayerAToMove) {
        [_playerA tellMakeMove:_state];
    } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
        [_playerB tellMakeMove:_state];
    }
}

- (void)setScreenEnabled:(BOOL)screenEnabled {
    _screenEnabled = screenEnabled;
    if (_screenEnabled) {
        // enable automatic move input by players (e.g. for AI players)
        _playerA.moveInputDelegate = self;
        _playerB.moveInputDelegate = self;
        
        // connect to game center event handler
        JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
        gameCenterManager.moveInputDelegate = self;
        gameCenterManager.currentMatchID = _matchID;
        
        // connect to board layer for move input
        _boardLayer.inputDelegate = self;
    } else {
        // disable automatic move input by players
        _playerA.moveInputDelegate = nil;
        _playerB.moveInputDelegate = nil;

        // disconnect from game center event handler
        JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
        gameCenterManager.currentMatchID = nil;
        gameCenterManager.moveInputDelegate = nil;

        // disconnect from board layer
        _boardLayer.inputDelegate = nil;
    }
}

- (void)disableMoveInput {
    _boardLayer.moveInputEnabled = NO;
    _skipItem.isEnabled = NO;
}

// update UI according to the current game state
- (void)updateUI {
    BOOL playerAEnabled = (_state.status == JCSFlipGameStatusPlayerAToMove && _playerA.localControls);
    BOOL playerBEnabled = (_state.status == JCSFlipGameStatusPlayerBToMove && _playerB.localControls);
    
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = playerAEnabled || playerBEnabled;
    _skipItem.isEnabled = _state.skipAllowed && (playerAEnabled || playerBEnabled);
}

- (void)updateScoreIndicatorAnimated:(BOOL)animated {
    [_scoreIndicator setScoreA:_state.cellCountPlayerA scoreB:_state.cellCountPlayerB animated:animated];
}

- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: selected start cell (%d,%d)", startRow, startColumn);
    if ([_state cellStateAtRow:startRow column:startColumn] == JCSFlipCellStateForGameStatus(_state.status)) {
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
    
    // determine the waiting player (to be notified after the move)
    id<JCSFlipPlayer> waitingPlayer = _state.status == JCSFlipGameStatusPlayerAToMove ? _playerB : _playerA;
    
    // apply the move
    if ([_state pushMove:move]) {
        // block move input during animation
        [self disableMoveInput];
        // update score indicator while animating the move
        [self updateScoreIndicatorAnimated:YES];
        [_boardLayer animateLastMoveOfGameState:_state afterAnimationInvokeBlock:^{
            // animation is done
            
            // notify waiting player
            [waitingPlayer opponentDidMakeMove:_state];
            
            // update UI
            [self updateUI];
            
            // notify next player
            if (_state.status == JCSFlipGameStatusPlayerAToMove) {
                [_playerA tellMakeMove:_state];
            } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
                [_playerB tellMakeMove:_state];
            }
        }];
    }
}


@end
