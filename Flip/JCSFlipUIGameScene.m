//
//  JCSFlipUIGameScene.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIGameScene.h"
#import "JCSFlipUIMainMenuScene.h"
#import "JCSFlipUIBoardLayer.h"
#import "JCSFlipCellState.h"
#import "JCSFlipUIBackgroundLayer.h"
#import "JCSFlipMove.h"
#import "JCSFlipUIGameOverLayer.h"

@implementation JCSFlipUIGameScene {
    JCSFlipGameState *_state;
    
    JCSFlipUIBoardLayer *_boardLayer;
    
    CCMenuItemFont *_skipButton;
    CCMenuItemFont *_exitButton;
}

@synthesize playerA = _playerA;
@synthesize playerB = _playerB;

+ (CCScene *)sceneWithState:(JCSFlipGameState *)state {
    return [[self alloc] initWithState:state];
}

- (id)initWithState:(JCSFlipGameState *)state {
    if (self = [super init]) {
        _state = state;
    }
    return self;
}

- (void)onEnter {
    [super onEnter];
    
    // both players must have been set
    NSAssert(_playerA != nil, @"playerA must be non-nil when the game scene enters the stage");
    NSAssert(_playerB != nil, @"playerB must be non-nil when the game scene enters the stage");
    
    JCSFlipUIBackgroundLayer *backgroundLayer = [[JCSFlipUIBackgroundLayer alloc] init];
    [self addChild:backgroundLayer z:0];
    
    CCDirector *director = [CCDirector sharedDirector];
    
    NSInteger windowWidth = director.winSize.width;
    NSInteger windowHeight = director.winSize.height;
    
    // center board layer' origin on screen, and scale properly
    // TODO: determine scale programmatically
    _boardLayer = [[JCSFlipUIBoardLayer alloc] initWithState:_state];
    _boardLayer.inputDelegate = self;
    _boardLayer.contentSize = CGSizeMake(5, 5);
    _boardLayer.anchorPoint = ccp(1, 0);
    _boardLayer.position = ccp(windowWidth, windowHeight/2);
    _boardLayer.scale = 96 * 0.4 * windowHeight / 320.0;
    [self addChild:_boardLayer z:1];
    
    ccColor3B menuColor = ccc3(0, 0, 127);
    
    _exitButton = [CCMenuItemFont itemWithString:@"Exit" block:^(id sender) {
        CCScene *scene = [JCSFlipUIMainMenuScene scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccc3(255, 255, 255)]];
    }];
    _exitButton.color = menuColor;
    _exitButton.anchorPoint = ccp(0,1);
    _exitButton.position = ccp(-windowWidth/2+10, windowHeight/2-10);
    
    _skipButton = [CCMenuItemFont itemWithString:@"Skip" block:^(id sender) {
        [self inputConfirmedWithMove:[JCSFlipMove moveSkip]];
    }];
    _skipButton.color = menuColor;
    _skipButton.anchorPoint = ccp(1,0);
    _skipButton.position = ccp(windowWidth/2-10, -windowHeight/2+10);
    
    CCMenu *menu = [CCMenu menuWithItems:_exitButton, _skipButton, nil];
    [self addChild:menu z:1];
    
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
}

// tell the current player to make a move
- (void)tellCurrentPlayerMakeMove {
    // determine current player
    id<JCSFlipPlayer> currentPlayer = nil;
    if (_state.status == JCSFlipGameStatusPlayerAToMove) {
        currentPlayer = _playerA;
    } else if (_state.status == JCSFlipGameStatusPlayerBToMove) {
        currentPlayer = _playerB;
    } else {
        NSString *text;
        if (_state.status == JCSFlipGameStatusPlayerAWon) {
            text = [NSString stringWithFormat:@"%d:%d - %@ wins!", _state.cellCountPlayerA, _state.cellCountPlayerB, _playerA.name];
        } else if (_state.status == JCSFlipGameStatusPlayerBWon) {
            text = [NSString stringWithFormat:@"%d:%d - %@ wins!", _state.cellCountPlayerA, _state.cellCountPlayerB, _playerB.name];
        } else {
            text = [NSString stringWithFormat:@"%d:%d - Draw!", _state.cellCountPlayerA, _state.cellCountPlayerB];
        }
        CCLayer *layer = [JCSFlipUIGameOverLayer layerWithText:text];
        [self addChild:layer z:2];
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

- (void)setPlayerA:(id<JCSFlipPlayer>)playerA {
    NSAssert(!self.isRunning, @"playerA may not be set if the scene is running");
    _playerA = playerA;
}

- (void)setPlayerB:(id<JCSFlipPlayer>)playerB {
    NSAssert(!self.isRunning, @"playerB may not be set if the scene is running");
    _playerB = playerB;
}

@end
