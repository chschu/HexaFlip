//
//  JCSFlipGameSelectionController.m
//  Flip
//
//  Created by Christian Schuster on 15.09.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameSelectionController.h"
#import "JCSFlipGameController.h"
#import "JCSFlipPlayer.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameStatePossessionHeuristic.h"
#import "JCSFlipGameStatePSRHeuristic.h"
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSRandomGameAlgorithm.h"

@implementation JCSFlipGameSelectionController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    
    void(^exitBlock)(id) = ^(id sender) {
        [self.navigationController popToViewController:self animated:YES];
    };
    
    if ([identifier isEqualToString:@"PlayerVsPlayer"]) {
        JCSFlipGameController *dest = segue.destinationViewController;
        dest.playerA = [self playerLocalWithName:@"Player A"];
        dest.playerB = [self playerLocalWithName:@"Player B"];
        dest.exitBlock = exitBlock;
    } else if ([identifier isEqualToString:@"PlayerVsAIEasy"]) {
        JCSFlipGameController *dest = segue.destinationViewController;
        dest.playerA = [self playerLocalWithName:@"Player"];
        dest.playerB = [self playerAIEasy];
        dest.exitBlock = exitBlock;
    } else if ([identifier isEqualToString:@"PlayerVsAIMedium"]) {
        JCSFlipGameController *dest = segue.destinationViewController;
        dest.playerA = [self playerLocalWithName:@"Player"];
        dest.playerB = [self playerAIMedium];
        dest.exitBlock = exitBlock;
    } else if ([identifier isEqualToString:@"PlayerVsAIHard"]) {
        JCSFlipGameController *dest = segue.destinationViewController;
        dest.playerA = [self playerLocalWithName:@"Player"];
        dest.playerB = [self playerAIHard];
        dest.exitBlock = exitBlock;
    } else {
        NSAssert(false, @"unknown segue identifier %@", identifier);
    }
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

- (id<JCSFlipPlayer>)playerAIRandomWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    id<JCSGameAlgorithm> algorithm = [[JCSRandomGameAlgorithm alloc] initWithSeed:time(0)];
    return [JCSFlipPlayerAI playerWithName:@"AI (random)" algorithm:algorithm];
}

@end
