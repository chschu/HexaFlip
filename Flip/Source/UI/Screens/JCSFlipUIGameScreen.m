//
//  JCSFlipUIGameScreen.m
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIGameScreen.h"
#import "JCSFlipUIBoardLayer.h"

@implementation JCSFlipUIGameScreen {
    JCSFlipGameState *_state;
    id<JCSFlipPlayer> _playerA;
    id<JCSFlipPlayer> _playerB;
    
    JCSFlipUIBoardLayer *_boardLayer;
    CCMenuItemFont *_exitButton;
    CCMenuItemFont *_skipButton;
    CCLabelTTF *_scoreLabel;
}

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

- (id)init {
    if (self = [super init]) {
        // create a dummy board layer
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // create the other controls
        _exitButton = [CCMenuItemFont itemWithString:@"Exit" block:^(id sender) {
            if (_screenEnabled) {
                // TODO what is the outcome here?
                [_delegate gameEndedWithStatus:JCSFlipGameStatusDraw];
            }
        }];
        _exitButton.anchorPoint = ccp(0,1);
        _exitButton.position = ccp(10, winSize.height-10);
        
        _skipButton = [CCMenuItemFont itemWithString:@"Skip" block:^(id sender) {
            if (_screenEnabled) {
                [self inputConfirmedWithMove:[JCSFlipMove moveSkip]];
            }
        }];
        _skipButton.anchorPoint = ccp(0,0);
        _skipButton.position = ccp(10, 10);
        
        CCMenu *menu = [CCMenu menuWithItems:_exitButton, _skipButton, nil];
        menu.anchorPoint = ccp(0,0);
        menu.position = ccp(0,0);
        [self addChild:menu z:1];
        
        _scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        _scoreLabel.anchorPoint = ccp(0,0.5);
        _scoreLabel.position = ccp(10, winSize.height/2.0);
        [self addChild:_scoreLabel z:1];
        
        // start a "dummy" game to initialize the board and UI state
        [self startGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:nil playerB:nil];
    }
    return self;
}

- (void)startGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // remove old board
    [_boardLayer removeFromParentAndCleanup:YES];
    
    // create new board, and center it vertically on the right border
    _state = state;
    _boardLayer = [JCSFlipUIBoardLayer nodeWithState:_state];
    _boardLayer.anchorPoint = ccp(1,0);
    _boardLayer.position = ccp(winSize.width,winSize.height/2);
    [self addChild:_boardLayer];
    
    // assign players
    _playerA = playerA;
    _playerB = playerB;
    
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
    _skipButton.isEnabled = NO;
}

// update UI according to the current game state, and notify the player to make his move
- (void)updateUIAndNotifyPlayer {
    BOOL playerAEnabled = (_state.status == JCSFlipGameStatusPlayerAToMove && _playerA.localControls);
    BOOL playerBEnabled = (_state.status == JCSFlipGameStatusPlayerBToMove && _playerB.localControls);
    
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = playerAEnabled || playerBEnabled;
    _skipButton.isEnabled = ((playerAEnabled || playerBEnabled) && _state.skipAllowed);
    _skipButton.isEnabled = _state.skipAllowed && (playerAEnabled || playerBEnabled);
    
    [self updateScoreLabel];
    
    // determine current player
    id<JCSFlipPlayer> currentPlayer = nil;
    if (_state.status == JCSFlipGameStatusPlayerAToMove) {
        currentPlayer = _playerA;
    } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
        currentPlayer = _playerB;
    } else {
        // notify the delegate that the game has ended
        [_delegate gameEndedWithStatus:_state.status];
    }
    
    // tell the current player to make a move
    [currentPlayer tellMakeMove:_state];
}

- (void)updateScoreLabel {
    _scoreLabel.string = [NSString stringWithFormat:@"%d:%d", _state.cellCountPlayerA, _state.cellCountPlayerB];
    switch (_state.status) {
        case JCSFlipGameStatusPlayerAToMove:
            _scoreLabel.color = ccc3(255, 0, 0);
            break;
        case JCSFlipGameStatusPlayerBToMove:
            _scoreLabel.color = ccc3(0, 0, 255);
            break;
        default:
            _scoreLabel.color = ccc3(0, 0, 0);
    }
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
        [_boardLayer animateLastMoveOfGameState:_state afterAnimationInvokeBlock:^{
            // animation is done - update UI and notify player
            [self updateUIAndNotifyPlayer];
        }];
    }
}


@end
