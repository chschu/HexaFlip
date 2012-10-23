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
#import "JCSFlipUIBackgroundLayer.h"
#import "JCSFlipMove.h"

@implementation JCSFlipUIGameScene {
    JCSFlipGameState *_state;
    
    JCSFlipUIBoardLayer *_boardLayer;
    
    CCMenuItemFont *_skipButton;
    CCMenuItemFont *_exitButton;
    
    CCLabelTTF *_scoreLabel;
    
    id<JCSFlipPlayer> _playerA;
    id<JCSFlipPlayer> _playerB;
    
    // block invoked when the game should be exited
    void(^_exitBlock)(id sender);
}

+ (JCSFlipUIGameScene *)sceneWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB exitBlock:(void(^)(id))exitBlock {
    return [[self alloc] initWithState:state playerA:playerA playerB:playerB exitBlock:exitBlock];
}

- (id)initWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB exitBlock:(void(^)())exitBlock {
    if (self = [super init]) {
        _state = state;
        _playerA = playerA;
        _playerA.moveInputDelegate = self;
        _playerB = playerB;
        _playerB.moveInputDelegate = self;
        _exitBlock = exitBlock;
    }
    return self;
}

- (void)onEnter {
    [super onEnter];
    
    JCSFlipUIBackgroundLayer *backgroundLayer = [[JCSFlipUIBackgroundLayer alloc] init];
    [self addChild:backgroundLayer z:0];
    
    CCDirector *director = [CCDirector sharedDirector];
    
    NSInteger windowWidth = director.winSize.width;
    NSInteger windowHeight = director.winSize.height;
    
    _boardLayer = [[JCSFlipUIBoardLayer alloc] initWithState:_state];
    _boardLayer.inputDelegate = self;
    
    // center board layer vertically, and place it on the right border
    _boardLayer.anchorPoint = ccp(1, 0);
    _boardLayer.position = ccp(windowWidth, windowHeight/2);
    [self addChild:_boardLayer z:1];
    
    ccColor3B menuColor = ccc3(0, 0, 0);
    
    _exitButton = [CCMenuItemFont itemWithString:@"Exit" block:_exitBlock];
    _exitButton.color = menuColor;
    _exitButton.anchorPoint = ccp(0,1);
    _exitButton.position = ccp(10, windowHeight-10);
    
    _skipButton = [CCMenuItemFont itemWithString:@"Skip" block:^(id sender) {
        [self inputConfirmedWithMove:[JCSFlipMove moveSkip]];
    }];
    _skipButton.color = menuColor;
    _skipButton.anchorPoint = ccp(0,0);
    _skipButton.position = ccp(10, 10);
    
    CCMenu *menu = [CCMenu menuWithItems:_exitButton, _skipButton, nil];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(0,0);
    [self addChild:menu z:1];
    
    _scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
    _scoreLabel.color = ccc3(0, 0, 0);
    _scoreLabel.anchorPoint = ccp(0,0.5);
    _scoreLabel.position = ccp(10, windowHeight/2.0);
    [self addChild:_scoreLabel z:1];
    
    [self updateUI];
    [self tellCurrentPlayerMakeMove];
}

- (void)disableMoveInput {
    _boardLayer.moveInputEnabled = NO;
    _skipButton.visible = NO;
}

// update UI according to the current game state
- (void)updateUI {
    // A enabled iff player A to move, and player A does not block input
    BOOL playerAEnabled = (_state.status == JCSFlipGameStatusPlayerAToMove && _playerA.localControls);
    BOOL playerBEnabled = (_state.status == JCSFlipGameStatusPlayerBToMove && _playerB.localControls);
    
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = playerAEnabled || playerBEnabled;
    _skipButton.visible = _state.skipAllowed && (playerAEnabled || playerBEnabled);
    
    // update score label
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

// tell the current player to make a move
- (void)tellCurrentPlayerMakeMove {
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
            [self updateUI];
            [self tellCurrentPlayerMakeMove];
        }];
    }
}

@end
