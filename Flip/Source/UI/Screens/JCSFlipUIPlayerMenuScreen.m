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

@implementation JCSFlipUIPlayerMenuScreen

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        __block id<JCSFlipPlayer> playerA = [self playerLocalWithName:@"Player A"];
        __block id<JCSFlipPlayer> playerB;
        
        // create back button
        CCMenuItem *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-back-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-back-pushed.png"] block:^(id sender) {
            [_delegate backFromPlayerMenuScreen:self];
        }];
        backItem.anchorPoint = ccp(0,1);
        backItem.position = ccp(-winSize.width/2+5, winSize.height/2-5);

        // create play button
        CCMenuItem *playItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-play-small-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-play-small-pushed.png"] disabledSprite:[CCSprite spriteWithSpriteFrameName:@"button-play-small-disabled.png"] block:^(id sender) {
            [_delegate startGameWithPlayerA:playerA playerB:playerB fromPlayerMenuScreen:self];
        }];
        playItem.anchorPoint = ccp(1,1);
        playItem.position = ccp(winSize.width/2-5, winSize.height/2-5);
        playItem.isEnabled = NO;
        
        // TODO icons
        CCMenuItem *playerItem = [CCMenuItemFont itemWithString:@"Human" block:^(id sender) {
            playerB = [self playerLocalWithName:@"Player B"];
            playItem.isEnabled = YES;
        }];
        playerItem.position = ccp(-150,40);
        
        CCMenuItem *aiEasyItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-ai-easy-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-ai-easy-pushed.png"] block:^(id sender) {
            playerB = [self playerAIEasy];
            playItem.isEnabled = YES;
        }];
        aiEasyItem.position = ccp(-50,-40);
        
        CCMenuItem *aiMediumItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-ai-medium-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-ai-medium-pushed.png"] block:^(id sender) {
            playerB = [self playerAIMedium];
            playItem.isEnabled = YES;
        }];
        aiMediumItem.position = ccp(50,40);

        CCMenuItem *aiHardItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"button-ai-hard-normal.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"button-ai-hard-pushed.png"] block:^(id sender) {
            playerB = [self playerAIHard];
            playItem.isEnabled = YES;
        }];
        aiHardItem.position = ccp(150,-40);

        CCMenu *menu = [CCMenu menuWithItems:backItem, playItem, nil];
        JCSRadioMenu *radioMenu = [JCSRadioMenu menuWithItems:playerItem, aiEasyItem, aiMediumItem, aiHardItem, nil];
        
        [self addChild:menu];
        [self addChild:radioMenu];
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
