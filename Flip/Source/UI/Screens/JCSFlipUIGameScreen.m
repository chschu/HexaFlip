//
//  JCSFlipUIGameScreen.m
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIGameScreen.h"
#import "JCSFlipUIBoardLayer.h"
#import "JCSButton.h"
#import "JCSFlipScoreIndicator.h"

@implementation JCSFlipUIGameScreen {
    JCSFlipGameState *_state;
    id<JCSFlipPlayer> _playerA;
    id<JCSFlipPlayer> _playerB;
    
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
            if (!_playerA.localControls) {
                if (!_playerB.localControls) {
                    // no player has local controls, no clear outcome
                    [_delegate gameEndedFromGameScreen:self];
                } else {
                    // only player B has local controls, so player A wins
                    [_delegate gameEndedWithStatus:JCSFlipGameStatusPlayerAWon fromGameScreen:self];
                }
            } else {
                if (!_playerB.localControls) {
                    // only player A has local controls, so player B wins
                    [_delegate gameEndedWithStatus:JCSFlipGameStatusPlayerBWon fromGameScreen:self];
                } else {
                    // both players have local controls, the player to move loses
                    if (_state.status == JCSFlipGameStatusPlayerAToMove) {
                        [_delegate gameEndedWithStatus:JCSFlipGameStatusPlayerBWon fromGameScreen:self];
                    } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
                        [_delegate gameEndedWithStatus:JCSFlipGameStatusPlayerAWon fromGameScreen:self];
                    } else {
                        [_delegate gameEndedFromGameScreen:self];
                    }
                }
            }
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
        [self prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:nil playerB:nil];
    }
    return self;
}

- (void)prepareGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB {
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

    // clear players
    _playerA = nil;
    _playerB = nil;
    
    // update UI (does not notify players, because they are not set)
    [self updateScoreIndicator];
    [self updateUIAndNotifyPlayer];
    
    // assign players (but don't notify yet)
    _playerA = playerA;
    _playerB = playerB;
}

- (void)startGame {
    NSAssert(_screenEnabled, @"screen must be enabled");
    NSAssert(_playerA != nil, @"playerA must not be nil");
    NSAssert(_playerB != nil, @"playerB must not be nil");

    [self updateUIAndNotifyPlayer];
}

- (void)setScreenEnabled:(BOOL)screenEnabled {
    _screenEnabled = screenEnabled;
    if (_screenEnabled) {
        // enable automatic move input by players (e.g. for AI players)
        _playerA.moveInputDelegate = self;
        _playerB.moveInputDelegate = self;
        
        // connect to board layer for move input
        _boardLayer.inputDelegate = self;
    } else {
        // disable automatic move input by players
        _playerA.moveInputDelegate = nil;
        _playerB.moveInputDelegate = nil;
        
        // disconnect from board layer
        _boardLayer.inputDelegate = nil;
    }
}

- (void)disableMoveInput {
    _boardLayer.moveInputEnabled = NO;
    _skipItem.isEnabled = NO;
}

// update UI according to the current game state, and notify the player to make his move
- (void)updateUIAndNotifyPlayer {
    BOOL playerAEnabled = (_state.status == JCSFlipGameStatusPlayerAToMove && _playerA.localControls);
    BOOL playerBEnabled = (_state.status == JCSFlipGameStatusPlayerBToMove && _playerB.localControls);
    
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = playerAEnabled || playerBEnabled;
    _skipItem.isEnabled = _state.skipAllowed && (playerAEnabled || playerBEnabled);
    
    // TODO show whose turn it is
    
    // determine current player
    id<JCSFlipPlayer> currentPlayer = nil;
    if (_state.status == JCSFlipGameStatusPlayerAToMove) {
        currentPlayer = _playerA;
    } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
        currentPlayer = _playerB;
    } else {
        // notify the delegate that the game has ended
        [_delegate gameEndedWithStatus:_state.status fromGameScreen:self];
    }
    
    // tell the current player to make a move
    [currentPlayer tellMakeMove:_state];
}

- (void)updateScoreIndicator {
    [_scoreIndicator setScoreA:_state.cellCountPlayerA scoreB:_state.cellCountPlayerB animationDuration:1];
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
    // TODO: visual
}

- (void)inputConfirmedWithMove:(JCSFlipMove *)move {
    NSLog(@"input: confirmed move %@", move);
    // apply the move
    if ([_state pushMove:move]) {
        // block move input during animation
        [self disableMoveInput];
        [self updateScoreIndicator];
        [_boardLayer animateLastMoveOfGameState:_state afterAnimationInvokeBlock:^{
            // animation is done - update UI and notify player
            [self updateUIAndNotifyPlayer];
        }];
    }
}


@end
