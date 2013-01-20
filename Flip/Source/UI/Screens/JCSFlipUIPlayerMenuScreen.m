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
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSRadioMenu.h"
#import "JCSButton.h"
#import "JCSFlipUIPlayerMenuScreenDelegate.h"

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
        
        CGFloat xDistance = JCSButtonSizeMedium*1.5; // horizontal distance between the centers of button columns
        CGFloat yDistance = 120; // vertical distance between the centers of button rows
        CGFloat xOffset = JCSButtonSizeSmall; // horizontal distance for the color chooser
        
        _playerAItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"player-a" block:^(id sender) {
            _playerIsPlayerA = YES;
        }];
        _playerAItem.position = ccp(-xOffset,yDistance/2);
        _playerBItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"player-b" block:^(id sender) {
            _playerIsPlayerA = NO;
        }];
        _playerBItem.position = ccp(xOffset,yDistance/2);

        // create (always-on) player button
        
        CCMenuItem *playerItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"human" block:nil];
        playerItem.position = ccp(0,yDistance/2);
        
        // create opponent buttons
        
        CCMenuItem *opponentAIEasyItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-easy" block:^(id sender) {
            self.opponent = [self playerAIEasy];
        }];
        opponentAIEasyItem.position = ccp(-xDistance,-yDistance/2);
        
        CCMenuItem *opponentAIMediumItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-medium"  block:^(id sender) {
            self.opponent = [self playerAIMedium];
        }];
        opponentAIMediumItem.position = ccp(0,-yDistance/2);
        
        CCMenuItem *opponentAIHardItem = [JCSButton buttonWithSize:JCSButtonSizeMedium name:@"ai-hard"  block:^(id sender) {
            self.opponent = [self playerAIHard];
        }];
        opponentAIHardItem.position = ccp(xDistance,-yDistance/2);
        
        CCMenu *menu = [CCMenu menuWithItems:backItem, _playItem, nil];
        JCSRadioMenu *playerRadioMenu = [JCSRadioMenu menuWithItems:playerItem, nil];
        JCSRadioMenu *opponentRadioMenu = [JCSRadioMenu menuWithItems:opponentAIEasyItem, opponentAIMediumItem, opponentAIHardItem, nil];
        _playerSideRadioMenu = [JCSRadioMenu menuWithItems:_playerAItem, _playerBItem, nil];
        
        // select the always-on player item
        playerRadioMenu.selectedItem = playerItem;
        
        [self addChild:menu z:1];
        [self addChild:playerRadioMenu z:1];
        [self addChild:opponentRadioMenu z:1];
        [self addChild:_playerSideRadioMenu z:2];
        
        // initialize the UI state
        [self updateUIState];
    }
    return self;
}

- (void)updateUIState {
    _playItem.isEnabled = (_opponent != nil);
    _playerSideRadioMenu.selectedItem = (_playerIsPlayerA ? _playerAItem : _playerBItem);
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
