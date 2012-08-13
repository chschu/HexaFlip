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
#import "JCSFlipGameStatePossessionHeuristic.h"
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
        scene.playerA = [self playerLocalWithName:@"Player (red)"];
        scene.playerB = [self playerLocalWithName:@"Player (blue)"];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccc3(255, 255, 255)]];
    }];
    playerVsPlayer.color = menuColor;
    
    CCMenuItemFont *playerVsAIEasy = [CCMenuItemFont itemWithString:@"Player vs. AI (easy)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [self playerLocalWithName:@"Player"];
        scene.playerB = [self playerAIEasyWithMoveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccc3(255, 255, 255)]];
    }];
    playerVsAIEasy.color = menuColor;

    CCMenuItemFont *playerVsAIMedium = [CCMenuItemFont itemWithString:@"Player vs. AI (medium)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [self playerLocalWithName:@"Player"];
        scene.playerB = [self playerAIMediumWithMoveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccc3(255, 255, 255)]];
    }];
    playerVsAIMedium.color = menuColor;

    CCMenuItemFont *playerVsAIHard = [CCMenuItemFont itemWithString:@"Player vs. AI (hard)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [self playerLocalWithName:@"Player"];
        scene.playerB = [self playerAIHardWithMoveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccc3(255, 255, 255)]];
    }];
    playerVsAIHard.color = menuColor;

    CCMenuItemFont *aiHardVsAIHard = [CCMenuItemFont itemWithString:@"AI (hard) vs. AI (hard)" block:^(id sender) {
        JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:[self createBoardOfSize:5]];
        scene.playerA = [self playerAIHardWithMoveInputDelegate:scene];
        scene.playerB = [self playerAIHardWithMoveInputDelegate:scene];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccc3(255, 255, 255)]];
    }];
    aiHardVsAIHard.color = menuColor;
    
    [self addChild:[CCLayerGradient layerWithColor:ccc4(255, 239, 191, 255) fadingTo:ccc4(255, 191, 127, 255)]];

    CCMenu *menu = [CCMenu menuWithItems:playerVsPlayer, playerVsAIEasy, playerVsAIMedium, playerVsAIHard, aiHardVsAIHard, nil];
    [menu alignItemsVertically];
    [self addChild:menu];
    
    NSString *buildString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    CCLabelTTF *buildLabel = [CCLabelTTF labelWithString:buildString fontName:@"Marker Felt" fontSize:12];
    buildLabel.anchorPoint = ccp(0, 0);
    buildLabel.position = ccp(5, 5);
    [self addChild:buildLabel];
}

- (id<JCSFlipPlayer>)playerLocalWithName:(NSString *)name {
    return [JCSFlipPlayerLocal playerWithName:name];
}

- (id<JCSFlipPlayer>)playerAIEasyWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePossessionHeuristic alloc] init];
    id<JCSGameAlgorithm> algorithm = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:1 heuristic:heuristic];
    return [JCSFlipPlayerAI playerWithName:@"AI (easy)" algorithm:algorithm moveInputDelegate:moveInputDelegate];
}

- (id<JCSFlipPlayer>)playerAIMediumWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePSRHeuristic alloc] initWithPossession:1 safety:0.3 randomness:0.4];
    id<JCSGameAlgorithm> algorithm = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:2 heuristic:heuristic];
    return [JCSFlipPlayerAI playerWithName:@"AI (medium)" algorithm:algorithm moveInputDelegate:moveInputDelegate];
}

- (id<JCSFlipPlayer>)playerAIHardWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePossessionHeuristic alloc] init];
    id<JCSGameAlgorithm> algorithm = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:4 heuristic:heuristic];
    return [JCSFlipPlayerAI playerWithName:@"AI (hard)" algorithm:algorithm moveInputDelegate:moveInputDelegate];
}

- (id<JCSFlipPlayer>)playerAIRandomWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    id<JCSGameAlgorithm> algorithm = [[JCSRandomGameAlgorithm alloc] initWithSeed:time(0)];
    return [JCSFlipPlayerAI playerWithName:@"AI (random)" algorithm:algorithm moveInputDelegate:moveInputDelegate];
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
