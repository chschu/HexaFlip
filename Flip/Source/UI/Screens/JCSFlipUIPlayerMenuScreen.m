//
//  JCSFlipUIPlayerMenuScreen.m
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIPlayerMenuScreen.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameStatePossessionHeuristic.h"
#import "JCSFlipGameStatePSRHeuristic.h"
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSRadioMenu.h"
#import "JCSButton.h"

@interface JCSFlipUIPlayerMenuScreen ()

@property id<JCSFlipPlayer> opponent;

@end

@implementation JCSFlipUIPlayerMenuScreen {
    CCMenuItem *_playItem;
    JCSRadioMenu *_playerSideRadioMenu;
    
    BOOL _playerIsPlayerA;
    CCMenuItem *_playerAItem;
    CCMenuItem *_playerBItem;
}

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

@synthesize opponent = _opponent;

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        id<JCSFlipPlayer> player = [self playerLocalWithName:@"Player"];
        
        // create back button
        CCMenuItem *backItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"back" block:^(id sender) {
            [_delegate backFromPlayerMenuScreen:self];
        }];
        backItem.anchorPoint = ccp(0,1);
        backItem.position = ccp(-winSize.width/2+10, winSize.height/2-10);
        
        _playerIsPlayerA = YES;
        
        // create play button
        _playItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"play" block:^(id sender) {
            id<JCSFlipPlayer> playerA = (_playerIsPlayerA ? player : _opponent);
            id<JCSFlipPlayer> playerB = (_playerIsPlayerA ? _opponent : player);
            [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
        }];
        _playItem.anchorPoint = ccp(1,1);
        _playItem.position = ccp(winSize.width/2-10, winSize.height/2-10);
        _playItem.isEnabled = NO;
        
        CGFloat xDistance = 80; // horizontal distance between the centers of button columns
        CGFloat yPosition = -20; // vertical center of opponent buttons
        CGFloat yDelta = 20; // vertical zig-zag distance of opponent buttons
        
        _playerAItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"player-a" block:^(id sender) {
            _playerIsPlayerA = YES;
        }];
        _playerAItem.position = ccp(180,yPosition+2.5*yDelta);
        _playerBItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"player-b" block:^(id sender) {
            _playerIsPlayerA = NO;
        }];
        _playerBItem.position = ccp(180,yPosition-2.5*yDelta);
        
        // create opponent buttons
        
        CCMenuItem *opponentHumanItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"human" block:^(id sender) {
            self.opponent = [self playerLocalWithName:@"Opponent"];
        }];
        opponentHumanItem.position = ccp(-180,yPosition+yDelta);
        
        CCMenuItem *opponentAIEasyItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-easy" block:^(id sender) {
            self.opponent = [self playerAIEasy];
        }];
        opponentAIEasyItem.position = ccp(-180+xDistance,yPosition-yDelta);
        
        CCMenuItem *opponentAIMediumItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-medium"  block:^(id sender) {
            self.opponent = [self playerAIMedium];
        }];
        opponentAIMediumItem.position = ccp(-180+2*xDistance,yPosition+yDelta);
        
        CCMenuItem *opponentAIHardItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-hard"  block:^(id sender) {
            self.opponent = [self playerAIHard];
        }];
        opponentAIHardItem.position = ccp(-180+3*xDistance,yPosition-yDelta);
        
        CCMenu *menu = [CCMenu menuWithItems:backItem, _playItem, nil];
        JCSRadioMenu *opponentRadioMenu = [JCSRadioMenu menuWithItems:opponentHumanItem, opponentAIEasyItem, opponentAIMediumItem, opponentAIHardItem, nil];
        _playerSideRadioMenu = [JCSRadioMenu menuWithItems:_playerAItem, _playerBItem, nil];
        
        [self addChild:menu];
        [self addChild:opponentRadioMenu];
        [self addChild:_playerSideRadioMenu];
        
        // initialize the UI state
        [self updateUIState];
    }
    return self;
}

- (void)updateUIState {
    _playItem.isEnabled = (_opponent != nil);
    _playerSideRadioMenu.selectedItem = (_playerIsPlayerA ? _playerAItem : _playerBItem);
    // TODO is this the right way to detect a local human opponent
    _playerSideRadioMenu.allSelectedMode = _opponent.localControls;
}

- (void)setOpponent:(id<JCSFlipPlayer>)opponent {
    _opponent = opponent;
    [self updateUIState];
}

- (id<JCSFlipPlayer>)opponent {
    return _opponent;
}

- (id<JCSFlipPlayer>)playerLocalWithName:(NSString *)name {
    return [JCSFlipPlayerLocal playerWithName:name];
}

- (id<JCSFlipPlayer>)playerAIEasy {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePossessionHeuristic alloc] init];
    id<JCSGameAlgorithm> algorithm = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:1 heuristic:heuristic];
    return [JCSFlipPlayerAI playerWithName:@"AI (easy)" algorithm:algorithm];
}

- (id<JCSFlipPlayer>)playerAIMedium {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0.3 randomness:0.4];
    id<JCSGameAlgorithm> algorithm = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:2 heuristic:heuristic];
    return [JCSFlipPlayerAI playerWithName:@"AI (medium)" algorithm:algorithm];
}

- (id<JCSFlipPlayer>)playerAIHard {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0.8 randomness:0.1];
    id<JCSGameAlgorithm> algorithm = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:4 heuristic:heuristic];
    return [JCSFlipPlayerAI playerWithName:@"AI (hard)" algorithm:algorithm];
}

@end
