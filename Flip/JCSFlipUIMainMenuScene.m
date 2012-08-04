//
//  JCSFlipUIMainMenuScene.m
//  Flip
//
//  Created by Christian Schuster on 01.08.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIMainMenuScene.h"
#import "JCSFlipUIGameScene.h"
#import "JCSFlipGameState.h"
#import "JCSGameHeuristic.h"
#import "JCSGameAlgorithm.h"
#import "JCSFlipGameStatePSRHeuristic.h"
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSRandomGameAlgorithm.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"

#import "cocos2d.h"

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) (MAX(MAX(abs((r1)-(r2)), abs((c1)-(c2))), abs((0-(r1)-(c1))-(0-(r2)-(c2)))))

@implementation JCSFlipUIMainMenuScene

+ (CCScene *)scene {
    return [[self alloc] init];
}

- (void)onEnter {
    [super onEnter];

    ccColor3B menuColor = ccc3(0, 0, 127);
    
    // TODO: player names?
    CCMenuItemFont *playerVsPlayer = [CCMenuItemFont itemWithString:@"Player vs. Player" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [[JCSFlipPlayerLocal alloc] initWithName:@"Red"];
        scene.playerB = [[JCSFlipPlayerLocal alloc] initWithName:@"Blue"];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:scene]];
    }];
    playerVsPlayer.color = menuColor;
    
    CCMenuItemFont *playerVsAIEasy = [CCMenuItemFont itemWithString:@"Player vs. AI (easy)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [[JCSFlipPlayerLocal alloc] initWithName:@"Player"];
        scene.playerB = [[JCSFlipPlayerAI alloc] initWithName:@"AI" algorithm:[self algorithmEasy] moveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:scene]];
    }];
    playerVsAIEasy.color = menuColor;

    CCMenuItemFont *playerVsAIMedium = [CCMenuItemFont itemWithString:@"Player vs. AI (medium)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [[JCSFlipPlayerLocal alloc] initWithName:@"Player"];
        scene.playerB = [[JCSFlipPlayerAI alloc] initWithName:@"AI" algorithm:[self algorithmMedium] moveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:scene]];
    }];
    playerVsAIMedium.color = menuColor;

    CCMenuItemFont *playerVsAIHard = [CCMenuItemFont itemWithString:@"Player vs. AI (hard)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [[JCSFlipPlayerLocal alloc] initWithName:@"Player"];
        scene.playerB = [[JCSFlipPlayerAI alloc] initWithName:@"AI" algorithm:[self algorithmHard] moveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:scene]];
    }];
    playerVsAIHard.color = menuColor;

    CCMenuItemFont *aiMediumVsAiHard = [CCMenuItemFont itemWithString:@"AI (medium) vs. AI (hard)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [[JCSFlipPlayerAI alloc] initWithName:@"Medium" algorithm:[self algorithmMedium] moveInputDelegate:scene];
        scene.playerB = [[JCSFlipPlayerAI alloc] initWithName:@"Hard" algorithm:[self algorithmHard] moveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:scene]];
    }];
    aiMediumVsAiHard.color = menuColor;

    CCMenuItemFont *aiBattle = [CCMenuItemFont itemWithString:@"Random AI Battle" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [[JCSFlipPlayerAI alloc] initWithName:@"Red" algorithm:[self algorithmRandom] moveInputDelegate:scene];
        scene.playerB = [[JCSFlipPlayerAI alloc] initWithName:@"Blue" algorithm:[self algorithmRandom] moveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5 scene:scene]];
    }];
    aiBattle.color = menuColor;

    [self addChild:[CCLayerGradient layerWithColor:ccc4(255, 239, 191, 255) fadingTo:ccc4(255, 191, 127, 255)]];

    CCMenu *menu = [CCMenu menuWithItems:playerVsPlayer, playerVsAIEasy, playerVsAIMedium, playerVsAIHard, aiMediumVsAiHard, aiBattle, nil];
    [menu alignItemsVertically];
    
    [self addChild:menu];
}

- (id<JCSGameAlgorithm>)algorithmEasy {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0 randomness:4];
    return [[JCSMinimaxGameAlgorithm alloc] initWithDepth:1 heuristic:heuristic];
}

- (id<JCSGameAlgorithm>)algorithmMedium {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0.4 randomness:2];
    return [[JCSMinimaxGameAlgorithm alloc] initWithDepth:2 heuristic:heuristic];
}

- (id<JCSGameAlgorithm>)algorithmHard {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0.8 randomness:0.2];
    return [[JCSMinimaxGameAlgorithm alloc] initWithDepth:3 heuristic:heuristic];
}

- (id<JCSGameAlgorithm>)algorithmRandom {
    return [[JCSRandomGameAlgorithm alloc] initWithSeed:time(0)];
}

- (JCSFlipGameState *)createBoardOfSize:(NSInteger)size {
    JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        NSInteger distanceFromOrigin = JCS_HEX_DISTANCE(row, column, 0, 0);
        if (distanceFromOrigin == 0 || distanceFromOrigin > size-1) {
            return JCSFlipCellStateHole;
        } else if (distanceFromOrigin == 1) {
            if (row + 2*column < 0) {
                return JCSFlipCellStateOwnedByPlayerA;
            } else {
                return JCSFlipCellStateOwnedByPlayerB;
            }
        } else {
            return JCSFlipCellStateEmpty;
        }
    };
    
    return [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
}

@end
