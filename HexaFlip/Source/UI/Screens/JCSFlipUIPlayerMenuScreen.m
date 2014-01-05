//
//  JCSFlipUIPlayerMenuScreen.m
//  HexaFlip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIPlayerMenuScreen.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameStatePossessionHeuristic.h"
#import "JCSFlipGameStatePSRHeuristic.h"
#import "JCSNegaScoutTTGameAlgorithm.h"
#import "JCSRadioMenu.h"
#import "JCSButton.h"
#import "JCSFlipUIPlayerMenuScreenDelegate.h"
#import "JCSFlipUICellNode.h"
#import "JCSFlipUIConstants.h"

typedef NS_ENUM(NSInteger, JCSFlipPlayerSelection) {
    JCSFlipPlayerSelectionNone,
    JCSFlipPlayerSelectionHuman,
    JCSFlipPlayerSelectionAIEasy,
    JCSFlipPlayerSelectionAIMedium,
    JCSFlipPlayerSelectionAIHard,
};

@implementation JCSFlipUIPlayerMenuScreen {
    JCSFlipPlayerSelection _playerASelection;
    JCSFlipPlayerSelection _playerBSelection;
    
    CCMenuItem *_playerAHumanItem;
    CCMenuItem *_playerAAIEasyItem;
    CCMenuItem *_playerAAIMediumItem;
    CCMenuItem *_playerAAIHardItem;

    CCMenuItem *_playerBHumanItem;
    CCMenuItem *_playerBAIEasyItem;
    CCMenuItem *_playerBAIMediumItem;
    CCMenuItem *_playerBAIHardItem;
}

@synthesize delegate = _delegate;

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // create back button
        CCMenuItem *backItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"back" block:^(id sender) {
            [_delegate backFromPlayerMenuScreen:self];
        }];
        backItem.anchorPoint = ccp(0.5,0.5);
        backItem.position = ccp(-winSize.width/2+10+JCSButtonSizeSmall/2.0, winSize.height/2-10-JCSButtonSizeSmall/2.0);
        
        _playerASelection = JCSFlipPlayerSelectionNone;
        _playerBSelection = JCSFlipPlayerSelectionNone;

        // create play button
        CCMenuItem *playItem = [JCSButton buttonWithSize:JCSButtonSizeLarge name:@"play" block:^(id sender) {
            id<JCSFlipPlayer> playerA = [self createPlayerOfType:_playerASelection];
            id<JCSFlipPlayer> playerB = [self createPlayerOfType:_playerBSelection];
            [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
        }];
        playItem.position = ccp(0,0);

        float xCenter = 100; // horizontal center ordinate of right player selection arc (left is at -xCenter)
        float yCenter = 0; // vertical center ordinate of player selection diamonds
        float distance = 85; // distance between adjacent player selection buttons on the same side

        // create player a buttons

        _playerAHumanItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"human" block:^(id sender) {
            _playerASelection = JCSFlipPlayerSelectionHuman;
        }];
        _playerAHumanItem.position = ccp(-xCenter,yCenter+distance);

        _playerAAIEasyItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-easy" block:^(id sender) {
            _playerASelection = JCSFlipPlayerSelectionAIEasy;
        }];
        _playerAAIEasyItem.position = ccp(-xCenter-distance/2*sqrt(3),yCenter+distance/2);

        _playerAAIMediumItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-medium" block:^(id sender) {
            _playerASelection = JCSFlipPlayerSelectionAIMedium;
        }];
        _playerAAIMediumItem.position = ccp(-xCenter-distance/2*sqrt(3),yCenter-distance/2);

        _playerAAIHardItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-hard" block:^(id sender) {
            _playerASelection = JCSFlipPlayerSelectionAIHard;
        }];
        _playerAAIHardItem.position = ccp(-xCenter,yCenter-distance);

        // create player b buttons
        
        _playerBHumanItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"human" block:^(id sender) {
            _playerBSelection = JCSFlipPlayerSelectionHuman;
        }];
        _playerBHumanItem.position = ccp(xCenter,yCenter+distance);
        
        _playerBAIEasyItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-easy" block:^(id sender) {
            _playerBSelection = JCSFlipPlayerSelectionAIEasy;
        }];
        _playerBAIEasyItem.position = ccp(xCenter+distance/2*sqrt(3),yCenter+distance/2);
        
        _playerBAIMediumItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-medium" block:^(id sender) {
            _playerBSelection = JCSFlipPlayerSelectionAIMedium;
        }];
        _playerBAIMediumItem.position = ccp(xCenter+distance/2*sqrt(3),yCenter-distance/2);
        
        _playerBAIHardItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-hard" block:^(id sender) {
            _playerBSelection = JCSFlipPlayerSelectionAIHard;
        }];
        _playerBAIHardItem.position = ccp(xCenter,yCenter-distance);

        // create legend cells
        
        JCSFlipUICellNode *playerACell = [JCSFlipUICellNode nodeWithRow:0 column:0 cellState:JCSFlipCellStateOwnedByPlayerA];
        playerACell.position = ccpAdd(ccp(-xCenter,yCenter),ccpMult(ccpFromSize(winSize), 0.5));
        playerACell.backgroundSprite.rotation = -15;
        
        JCSFlipUICellNode *playerBCell = [JCSFlipUICellNode nodeWithRow:0 column:0 cellState:JCSFlipCellStateOwnedByPlayerB];
        playerBCell.position = ccpAdd(ccp(xCenter,yCenter),ccpMult(ccpFromSize(winSize), 0.5));
        playerBCell.backgroundSprite.rotation = -15;
        
        CCMenu *menu = [CCMenu menuWithItems:backItem, playItem, nil];
        JCSRadioMenu *playerARadioMenu = [JCSRadioMenu menuWithItems:_playerAHumanItem, _playerAAIEasyItem, _playerAAIMediumItem, _playerAAIHardItem, nil];
        JCSRadioMenu *playerBRadioMenu = [JCSRadioMenu menuWithItems:_playerBHumanItem, _playerBAIEasyItem, _playerBAIMediumItem, _playerBAIHardItem, nil];
        
        // pre-select radio items
        playerARadioMenu.selectedItem = _playerAHumanItem;
        playerBRadioMenu.selectedItem = _playerBAIMediumItem;
        
        [self addChild:menu z:1];
        [self addChild:playerARadioMenu z:2];
        [self addChild:playerBRadioMenu z:2];
        [self addChild:playerACell z:1];
        [self addChild:playerBCell z:1];
    }
    return self;
}

- (id<JCSFlipPlayer>)createPlayerOfType:(JCSFlipPlayerSelection)playerSelection {
    id<JCSFlipPlayer> player;
    id<JCSGameHeuristic> heuristic;
    JCSTranspositionTable *transpositionTable;
    id<JCSGameAlgorithm> algorithm;
    switch (playerSelection) {
        case JCSFlipPlayerSelectionHuman:
            player = [JCSFlipPlayerLocal player];
            break;
        case JCSFlipPlayerSelectionAIEasy:
            heuristic = [[JCSFlipGameStatePossessionHeuristic alloc] init];
            transpositionTable = [[JCSTranspositionTable alloc] initWithSize:JCS_TRANSPOSITION_TABLE_SIZE];
            algorithm = [[JCSNegaScoutTTGameAlgorithm alloc] initWithDepth:1 heuristic:heuristic transpositionTable:transpositionTable];
            player = [JCSFlipPlayerAI playerWithAlgorithm:algorithm];
            break;
        case JCSFlipPlayerSelectionAIMedium:
            heuristic = [[JCSFlipGameStatePossessionHeuristic alloc] init];
            transpositionTable = [[JCSTranspositionTable alloc] initWithSize:JCS_TRANSPOSITION_TABLE_SIZE];
            algorithm = [[JCSNegaScoutTTGameAlgorithm alloc] initWithDepth:4 heuristic:heuristic transpositionTable:transpositionTable];
            player = [JCSFlipPlayerAI playerWithAlgorithm:algorithm];
            break;
        case JCSFlipPlayerSelectionAIHard:
            heuristic = [[JCSFlipGameStatePossessionHeuristic alloc] init];
            transpositionTable = [[JCSTranspositionTable alloc] initWithSize:JCS_TRANSPOSITION_TABLE_SIZE];
            algorithm = [[JCSNegaScoutTTGameAlgorithm alloc] initWithDepth:6 heuristic:heuristic transpositionTable:transpositionTable];
            player = [JCSFlipPlayerAI playerWithAlgorithm:algorithm];
            break;
        default:
            NSAssert(NO, @"invalid playerSelection %d", playerSelection);
    }
    return player;
}

- (void)setScreenEnabled:(BOOL)screenEnabled completion:(void(^)())completion {
    _screenEnabled = screenEnabled;
    if (completion != nil) {
        completion();
    }
}

- (BOOL)leaveScreenWhenPlayerLoggedOut {
    return NO;
}

@end
