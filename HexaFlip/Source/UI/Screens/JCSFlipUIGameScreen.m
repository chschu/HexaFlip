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
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameCenterManager.h"
#import "JCSFlipUIConstants.h"
#import "JCSFlipUIEvents.h"

@implementation JCSFlipUIGameScreen {
    JCSFlipGameState *_state;
    id<JCSFlipPlayer> _playerA;
    id<JCSFlipPlayer> _playerB;
    GKTurnBasedMatch *_match;
    
    // the last move, to be animated on game start (may be nil)
    JCSFlipMove *_lastMove;
    
    // flag to globally disable move input
    BOOL _moveInputDisabled;
    
    JCSFlipUIBoardLayer *_boardLayer;
    CCMenuItem *_undoItem;
    CCMenuItem *_skipItem;
    JCSFlipScoreIndicator *_scoreIndicator;
    
    CCSprite *_outcomeSpriteBackground;
    CCSprite *_outcomeSpriteOverlayWon;
    CCSprite *_outcomeSpriteOverlayDraw;
}

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

        // create the exit button
        CCMenuItem *exitItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"back" block:^(id sender) {
            // notify players (cancels AI)
            [_playerA cancel];
            [_playerB cancel];
            
            // cancel potential move input
            [_boardLayer cancelMoveInput];

            // prepare notification data
            JCSFlipUIExitGameEventData *data = [[JCSFlipUIExitGameEventData alloc] initWithMultiplayer:[self isMultiplayerGame]];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:data forKey:JCS_FLIP_UI_EVENT_DATA_KEY];

            // leave
            [nc postNotificationName:JCS_FLIP_UI_EXIT_GAME_EVENT_NAME object:self userInfo:userInfo];
        }];
        exitItem.anchorPoint = ccp(0.5,0.5);
        exitItem.position = ccp(-winSize.width/2+10+JCSButtonSizeSmall/2.0, winSize.height/2-10-JCSButtonSizeSmall/2.0);
        
        // create the undo button
        _undoItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"undo" block:^(id sender) {
            // remove outcome sprite
            [self removeOutcomeSprite];
            
            // cancel potential move input
            [_boardLayer cancelMoveInput];
            
            // undo at most 1 move if two players are local
            // undo at most 2 moves if one player is local
            // if no player is local, the button is disabled elsewhere
            // the move stack size imposes another upper bound on the number of moves
            NSUInteger movesToUndo = MIN(_playerA.localControls && _playerB.localControls ? 1 : 2, _state.moveStackSize);
            [self undoMoves:movesToUndo];
        }];
        _undoItem.anchorPoint = ccp(0.5,0.5);
        _undoItem.position = ccp(-winSize.width/2+10+JCSButtonSizeSmall+10+JCSButtonSizeSmall/2.0, -winSize.height/2+10+JCSButtonSizeSmall/2.0);
        
        // create the skip button
        _skipItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"skip" block:^(id sender) {
            // cancel potential move input
            [_boardLayer cancelMoveInput];
            
            // perform move input
            [self inputConfirmedWithMove:[JCSFlipMove moveSkip]];
        }];
        _skipItem.anchorPoint = ccp(0.5,0.5);
        _skipItem.position = ccp(-winSize.width/2+10+JCSButtonSizeSmall/2.0, -winSize.height/2+10+JCSButtonSizeSmall/2.0);
        
        CCMenu *menu = [CCMenu menuWithItems:exitItem, _undoItem, _skipItem, nil];
        [self addChild:menu z:2];
        
        _scoreIndicator = [JCSFlipScoreIndicator node];
        _scoreIndicator.anchorPoint = ccp(0.5,0.5);
        _scoreIndicator.position = ccp(10+JCSButtonSizeSmall/2.0,winSize.height/2.0);
        [self addChild:_scoreIndicator z:1];
        
        // prepare a "dummy" game to initialize the board and UI state
        [self prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5 playerToMove:JCSFlipPlayerSideA] playerA:nil playerB:nil match:nil animateLastMove:NO moveInputDisabled:YES];
        
        // create hidden outcome sprites, centered over board
        _outcomeSpriteBackground = [CCSprite spriteWithSpriteFrameName:@"outcome-background.png"];
        _outcomeSpriteBackground.anchorPoint = ccp(0.5,0.5);
        _outcomeSpriteBackground.position = [self convertToNodeSpace:[_boardLayer convertToWorldSpace:ccp(0,0)]];
        _outcomeSpriteBackground.visible = NO;
        [self addChild:_outcomeSpriteBackground z:4];
        _outcomeSpriteOverlayWon = [CCSprite spriteWithSpriteFrameName:@"outcome-overlay-won.png"];
        _outcomeSpriteOverlayWon.anchorPoint = ccp(0.5,0.5);
        _outcomeSpriteOverlayWon.position = [self convertToNodeSpace:[_boardLayer convertToWorldSpace:ccp(0,0)]];
        _outcomeSpriteOverlayWon.visible = NO;
        [self addChild:_outcomeSpriteOverlayWon z:5];
        _outcomeSpriteOverlayDraw = [CCSprite spriteWithSpriteFrameName:@"outcome-overlay-draw.png"];
        _outcomeSpriteOverlayDraw.anchorPoint = ccp(0.5,0.5);
        _outcomeSpriteOverlayDraw.position = [self convertToNodeSpace:[_boardLayer convertToWorldSpace:ccp(0,0)]];
        _outcomeSpriteOverlayDraw.visible = NO;
        [self addChild:_outcomeSpriteOverlayDraw z:5];
    }
    return self;
}

- (void)prepareGameWithState:(JCSFlipGameState *)state playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled {
    NSAssert(state != nil, @"state must not be nil");
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // remove old board
    [_boardLayer removeFromParentAndCleanup:YES];
    
    // remove thinking indicator (might still be present from previous game)
    [self removeThinkingIndicator];
    
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
    
    // store move input disabling flag
    _moveInputDisabled = moveInputDisabled;
    
    // update UI
    [self removeOutcomeSprite];
    [self updateScoreIndicatorAnimated:NO];
    [self enableMoveInput];
}

- (void)removeOutcomeSprite {
    _outcomeSpriteBackground.visible = NO;
    _outcomeSpriteOverlayWon.visible = NO;
    _outcomeSpriteOverlayDraw.visible = NO;
}

- (id<JCSFlipPlayer>)playerToMove {
    return (_state.playerToMove == JCSFlipPlayerSideA) ? _playerA : _playerB;
}

// notify current player that opponent did make a move
- (void)tellPlayerOpponentDidMakeMove {
    [[self playerToMove] opponentDidMakeMove:_state];
}

// notify current player to make his move, unless game is over
// show game over animation, if game is over
- (void)tellPlayerMakeMove {
    JCSFlipGameStatus status = _state.status;
    if (!JCSFlipGameStatusIsOver(status)) {
        // show thinking indicator BEFORE telling the player to make a move (might otherwise modify state too early)
        [self startThinkingIndicatorAnimation];
        
        // now activate the player
        [[self playerToMove] tellMakeMove:_state];
    } else {
        NSLog(@"game is over, showing animation");
        _outcomeSpriteBackground.visible = YES;
        _outcomeSpriteBackground.color = [self outcomeSpriteBackgroundColorForGameStatus:status];
        _outcomeSpriteBackground.scale = 0;
        _outcomeSpriteBackground.rotation = 0;
        
        CCSprite *outcomeSpriteOverlay = (status == JCSFlipGameStatusDraw ? _outcomeSpriteOverlayDraw : _outcomeSpriteOverlayWon);
        outcomeSpriteOverlay.visible = YES;
        outcomeSpriteOverlay.scale = 0;
        
        CCFiniteTimeAction *scale = [CCScaleTo actionWithDuration:JCS_FLIP_UI_OUTCOME_ANIMATION_DURATION scale:0.8];
        CCFiniteTimeAction *rotate = [CCRotateTo actionWithDuration:JCS_FLIP_UI_OUTCOME_ANIMATION_DURATION angle:90+15];
        CCActionInterval *scaleRotate = [CCSpawn actionOne:scale two:rotate];
        CCFiniteTimeAction *backgroundAction = [CCTargetedAction actionWithTarget:_outcomeSpriteBackground action:scaleRotate];
        CCFiniteTimeAction *overlayAction = [CCTargetedAction actionWithTarget:outcomeSpriteOverlay action:[scale copy]];
        CCActionInterval *spawn = [CCSpawn actionOne:backgroundAction two:overlayAction];
        CCAction *easedAction = [CCEaseElasticOut actionWithAction:spawn];
        
        [self runAction:easedAction];
    }
}

#define TAG_THINKING_INDICATOR 5

- (void)startThinkingIndicatorAnimation {
    // collect animation frames
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    id<JCSFlipPlayer> player = [self playerToMove];
    NSUInteger frameCount = player.activityIndicatorSpriteFrameCount;
    
    // start animation if there are any frames
    if (frameCount > 0) {
        NSMutableArray *animFrames = [NSMutableArray array];
        NSString *format = player.activityIndicatorSpriteFrameNameFormat;
        for (int i = 1; i <= frameCount; i++) {
            [animFrames addObject:[cache spriteFrameByName:[NSString stringWithFormat:format, i]]];
        }
        
        // create animation without delay after showing the last frame
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:animFrames.lastObject];
        sprite.color = (_state.playerToMove == JCSFlipPlayerSideA ? ccRED : ccBLUE);
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:[animFrames subarrayWithRange:NSMakeRange(0, frameCount-1)] delay:0.25];
        animation.restoreOriginalFrame = YES;
        
        // set sprite position and anchor point defined by the player implementation
        sprite.anchorPoint = player.activityIndicatorAnchorPoint;
        sprite.position = [self convertToNodeSpace:[_boardLayer convertToWorldSpace:player.activityIndicatorPosition]];
        
        // start animation
        CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
        [sprite runAction:animate];
        
        // slightly scale up and down to create a "wobble" effect
        CCScaleTo *scaleDown = [CCScaleTo actionWithDuration:0.75 scale:0.95];
        CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.75 scale:1.0];
        CCEaseSineInOut *easedScaleDown = [CCEaseSineInOut actionWithAction:scaleDown];
        CCEaseSineInOut *easedScaleUp = [CCEaseSineInOut actionWithAction:scaleUp];
        CCSequence *wobble = [CCSequence actionOne:easedScaleDown two:easedScaleUp];
        CCRepeatForever *wobbleForever = [CCRepeatForever actionWithAction:wobble];
        [sprite runAction:wobbleForever];
        
        // fade in
        sprite.opacity = 0;
        [sprite runAction:[CCFadeTo actionWithDuration:JCS_FLIP_UI_THINKING_INDICATOR_FADE_DURATION opacity:255]];
        
        [self addChild:sprite z:5 tag:TAG_THINKING_INDICATOR];
    }
}

- (void)removeThinkingIndicator {
    [self removeChildByTag:TAG_THINKING_INDICATOR];
}

- (void)stopThinkingIndicatorAnimationWithCompletion:(void(^)())completion {
    CCNode *indicator = [self getChildByTag:TAG_THINKING_INDICATOR];
    if (indicator != nil) {
        // fade out, remove indicator and invoke completion
        CCSequence *sequence = [CCSequence actionOne:[CCFadeTo actionWithDuration:JCS_FLIP_UI_THINKING_INDICATOR_FADE_DURATION opacity:0] two:[CCCallBlock actionWithBlock:^{
            [self removeThinkingIndicator];
            if (completion != nil) {
                completion();
            }
        }]];
        [indicator runAction:sequence];
    } else {
        // invoke completion immediately
        if (completion != nil) {
            completion();
        }
    }
}

- (ccColor3B)outcomeSpriteBackgroundColorForGameStatus:(JCSFlipGameStatus)status {
    ccColor3B result;
    if (status == JCSFlipGameStatusPlayerAWon) {
        result = ccRED;
    } else if (status == JCSFlipGameStatusPlayerBWon) {
        result = ccBLUE;
    } else if (status == JCSFlipGameStatusDraw) {
        result = ccWHITE;
    } else {
        NSAssert(NO, @"invalid status");
    }
    return result;
}

- (void)startGame {
    if (_lastMove != nil) {
        // apply the move, but don't tell the opponent that the move has been made ("replay")
        BOOL success = [self applyMove:_lastMove replay:YES];
        NSAssert(success, @"unable to apply last move");
        _lastMove = nil;
    } else {
        [self tellPlayerMakeMove];
    }
}

// returns YES if the current (prepared or started) game is a multiplayer game
- (BOOL)isMultiplayerGame {
    return _match != nil;
}

- (void)didActivateScreen {
    // enable automatic move input by players (e.g. for AI players)
    if ([_playerA respondsToSelector:@selector(setMoveInputDelegate:)]) {
        _playerA.moveInputDelegate = self;
    }
    if ([_playerB respondsToSelector:@selector(setMoveInputDelegate:)]) {
        _playerB.moveInputDelegate = self;
    }
    
    // connect to game center event handler
    JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
    gameCenterManager.moveInputDelegate = self;
    gameCenterManager.currentMatch = _match;
    
    // connect to board layer for move input
    _boardLayer.inputDelegate = self;
    
    // start the game (must have been prepared before)
    [self startGame];
}

- (void)didDeactivateScreen {
    // disable automatic move input by players
    if ([_playerA respondsToSelector:@selector(setMoveInputDelegate:)]) {
        _playerA.moveInputDelegate = nil;
    }
    if ([_playerB respondsToSelector:@selector(setMoveInputDelegate:)]) {
        _playerB.moveInputDelegate = nil;
    }
    
    // disconnect from game center event handler
    JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
    gameCenterManager.currentMatch = nil;
    gameCenterManager.moveInputDelegate = nil;
    
    // disconnect from board layer
    _boardLayer.inputDelegate = nil;
}

- (BOOL)leaveScreenWhenPlayerLoggedOut {
    // don't care about Game Center authentication for local matches
    return _match != nil;
}

// disable move input completely
- (void)disableMoveInput {
    _boardLayer.moveInputEnabled = NO;
    _skipItem.isEnabled = NO;
    _undoItem.isEnabled = NO;
}

// enable move input according to the current game state
- (void)enableMoveInput {
    BOOL gameOver = JCSFlipGameStatusIsOver(_state.status);
    BOOL playerAEnabled = !_moveInputDisabled && _state.playerToMove == JCSFlipPlayerSideA && _playerA.localControls;
    BOOL playerBEnabled = !_moveInputDisabled && _state.playerToMove == JCSFlipPlayerSideB && _playerB.localControls;
    BOOL anyPlayerEnabled = playerAEnabled || playerBEnabled;
    
    // enable/disable move input if any of the players has local controls
    _boardLayer.moveInputEnabled = !gameOver && anyPlayerEnabled;
    _skipItem.isEnabled = _state.skipAllowed && anyPlayerEnabled;
    _undoItem.visible = ![self isMultiplayerGame];
    
    if (anyPlayerEnabled) {
        // undo is possible if the move stack is not empty
        _undoItem.isEnabled = (_state.moveStackSize > 0);
    } else {
        // undo is impossible if no player has local controls
        _undoItem.isEnabled = NO;
    }
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
        // animate the move
        [_boardLayer animateLastMoveOfGameState:_state undo:NO afterAnimationInvokeBlock:^{
            // remove thinking indicator
            [self stopThinkingIndicatorAnimationWithCompletion:^{
                // enable move input
                [self enableMoveInput];
                
                // notify opponent (new current player)
                if (!replay) {
                    [self tellPlayerOpponentDidMakeMove];
                }
                [self tellPlayerMakeMove];
            }];
        }];
    }
    return success;
}

// animates the last move of the current game state in reverse, and pops the moves from the game state
// the process is repeated recursively until count is zero
// not allowed for multi-player games
- (void)undoMoves:(NSUInteger)count {
    NSAssert(![self isMultiplayerGame], @"undo not allowed for multiplayer games");
    
    if (count > 0) {
        // undo the move if this is the first invocation, or
        
        // block move input during animation
        [self disableMoveInput];
        
        // remove thinking indicator
        [self stopThinkingIndicatorAnimationWithCompletion:^{
            // temporarily pop move to update score indicator while undo is animated
            JCSFlipMove *lastMove = _state.lastMove;
            [_state popMove];
            [self updateScoreIndicatorAnimated:YES];
            [_state pushMove:lastMove];
            
            // animate undo of last move
            [_boardLayer animateLastMoveOfGameState:_state undo:YES afterAnimationInvokeBlock:^{
                // pop the move from the game state
                [_state popMove];
                // undo the remaining moves
                [self undoMoves:count-1];
            }];
        }];
    } else {
        // enable move input
        [self enableMoveInput];
        
        // notify opponent (new current player)
        [self tellPlayerMakeMove];
    }
}

- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: selected start cell (%d,%d)", startRow, startColumn);
    if ([_state cellStateAtRow:startRow column:startColumn] == JCSFlipCellStateForPlayerSide(_state.playerToMove)) {
        [_boardLayer startFlashForCellAtRow:startRow column:startColumn];
        return YES;
    }
    return NO;
}

- (void)inputClearedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: cleared start cell");
    [_boardLayer stopFlashForCellAtRow:startRow column:startColumn];
}

- (BOOL)inputModifiedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn previousStartRow:(NSInteger)previousStartRow previousStartColumn:(NSInteger)previousStartColumn {
    NSLog(@"input: modified start cell (%d,%d)", startRow, startColumn);
    if ([_state cellStateAtRow:startRow column:startColumn] == JCSFlipCellStateForPlayerSide(_state.playerToMove)) {
        [_boardLayer stopFlashForCellAtRow:previousStartRow column:previousStartColumn];
        [_boardLayer startFlashForCellAtRow:startRow column:startColumn];
        return YES;
    }
    return NO;
}

- (void)inputSelectedDirection:(JCSHexDirection)direction startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    NSLog(@"input: selected direction %d", direction);
    
    // check if the move is valid
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:startRow startColumn:startColumn direction:direction];
    if ([_state pushMove:move]) {
        // flash all cells involved in the move
        // this also re-triggers the flash of the start cell to get it in sync
        [_state forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop) {
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
        [_state forAllCellsInvolvedInLastMoveReverse:NO invokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop) {
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
