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
        CCMenuItem *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-small-back-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-small-back-pushed.png"] block:^(id sender) {
            [_delegate backFromPlayerMenuScreen:self];
        }];
        backItem.anchorPoint = ccp(0,1);
        backItem.position = ccp(-winSize.width/2+5, winSize.height/2-5);

        _playerIsPlayerA = YES;

        // create play button
        _playItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-small-play-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-small-play-pushed.png"] disabledSprite:[CCSprite spriteWithSpriteFrameName:@"button-small-play-disabled.png"] block:^(id sender) {
            id<JCSFlipPlayer> playerA = (_playerIsPlayerA ? player : _opponent);
            id<JCSFlipPlayer> playerB = (_playerIsPlayerA ? _opponent : player);
            [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
        }];
        _playItem.anchorPoint = ccp(1,1);
        _playItem.position = ccp(winSize.width/2-5, winSize.height/2-5);
        _playItem.isEnabled = NO;
        
        CGFloat xDistance = 80; // horizontal distance between the centers of button columns
        CGFloat yDelta = 20; // vertical zig-zag distance of opponent buttons
        
        // TODO icons
        _playerAItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-player-a-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-player-a-pushed.png"] block:^(id sender) {
            _playerIsPlayerA = YES;
        }];
        _playerAItem.position = ccp(180,40);
        _playerBItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-player-b-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-player-b-pushed.png"] block:^(id sender) {
            _playerIsPlayerA = NO;
        }];
        _playerBItem.position = ccp(180,-40);
        
        // TODO icons
        CCMenuItem *opponentHumanItem = [CCMenuItemFont itemWithString:@"Human" block:^(id sender) {
            self.opponent = [self playerLocalWithName:@"Player A"];
        }];
        opponentHumanItem.position = ccp(-180,yDelta);
        
        CCMenuItem *opponentAIEasyItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-ai-easy-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-ai-easy-pushed.png"] block:^(id sender) {
            self.opponent = [self playerAIEasy];
        }];
        opponentAIEasyItem.position = ccp(-180+xDistance,-yDelta);
        
        CCMenuItem *opponentAIMediumItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-ai-medium-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-ai-medium-pushed.png"] block:^(id sender) {
            self.opponent = [self playerAIMedium];
        }];
        opponentAIMediumItem.position = ccp(-180+2*xDistance,yDelta);
        
        CCMenuItem *opponentAIHardItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-ai-hard-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-medium-ai-hard-pushed.png"] block:^(id sender) {
            self.opponent = [self playerAIHard];
        }];
        opponentAIHardItem.position = ccp(-180+3*xDistance,-yDelta);
        
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
