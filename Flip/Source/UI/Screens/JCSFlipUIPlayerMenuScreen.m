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

@implementation JCSFlipUIPlayerMenuScreen

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // create the other controls
        CCMenuItem *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-back-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-back-pushed.png"] block:^(id sender) {
            if (_screenEnabled) {
                [_delegate backFromPlayerMenuScreen:self];
            }
        }];
        backItem.anchorPoint = ccp(0,1);
        backItem.position = ccp(-winSize.width/2+5, winSize.height/2-5);
        
        CCMenuItem *playerVsPlayerItem = [CCMenuItemFont itemWithString:@"Player vs. Player" block:^(id sender) {
            if (_screenEnabled) {
                id<JCSFlipPlayer> playerA = [self playerLocalWithName:@"Player A"];
                id<JCSFlipPlayer> playerB = [self playerLocalWithName:@"Player B"];
                [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
            }
        }];
        playerVsPlayerItem.position = ccp(0,80);
        
        CCMenuItem *playerVsAIEasyItem = [CCMenuItemFont itemWithString:@"Player vs. AI Easy" block:^(id sender) {
            if (_screenEnabled) {
                id<JCSFlipPlayer> playerA = [self playerLocalWithName:@"Player A"];
                id<JCSFlipPlayer> playerB = [self playerAIEasy];
                [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
            }
        }];
        playerVsAIEasyItem.position = ccp(0,40);

        CCMenuItem *playerVsAIMediumItem = [CCMenuItemFont itemWithString:@"Player vs. AI Medium" block:^(id sender) {
            if (_screenEnabled) {
                id<JCSFlipPlayer> playerA = [self playerLocalWithName:@"Player A"];
                id<JCSFlipPlayer> playerB = [self playerAIMedium];
                [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
            }
        }];
        playerVsAIMediumItem.position = ccp(0,0);

        CCMenuItem *playerVsAIHardItem = [CCMenuItemFont itemWithString:@"Player vs. AI Hard" block:^(id sender) {
            if (_screenEnabled) {
                id<JCSFlipPlayer> playerA = [self playerLocalWithName:@"Player A"];
                id<JCSFlipPlayer> playerB = [self playerAIHard];
                [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
            }
        }];
        playerVsAIHardItem.position = ccp(0,-40);

        CCMenuItem *battleAI = [CCMenuItemFont itemWithString:@"AI Easy vs. AI Easy" block:^(id sender) {
            if (_screenEnabled) {
                id<JCSFlipPlayer> playerA = [self playerAIEasy];
                id<JCSFlipPlayer> playerB = [self playerAIEasy];
                [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
            }
        }];
        battleAI.position = ccp(0,-80);

        CCMenu *menu = [CCMenu menuWithItems:backItem, playerVsPlayerItem, playerVsAIEasyItem, playerVsAIMediumItem, playerVsAIHardItem, battleAI, nil];
        
        [self addChild:menu];
    }
    return self;
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
