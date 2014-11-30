//
//  JCSFlipPlayerGameCenter.m
//  HexaFlip
//
//  Created by Christian Schuster on 12.12.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerGameCenter.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipGameCenterManager.h"
#import "JCSFlipUIEvents.h"

#import "cocos2d.h"

@implementation JCSFlipPlayerGameCenter

+ (instancetype)player {
    return [[self alloc] init];
}

- (BOOL)localControls {
    return NO;
}

- (NSString *)activityIndicatorSpriteFrameNameFormat {
    return @"indicator-game-center-frame-%d.png";
}

- (NSUInteger)activityIndicatorSpriteFrameCount {
    return 1;
}

- (CGPoint)activityIndicatorAnchorPoint {
    return ccp(0.5,0.5);
}

- (CGPoint)activityIndicatorPosition {
    return ccp(-180,60);
}

- (void)opponentDidMakeMove:(JCSFlipGameState *)state {
    JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
    
    // generate data for game center
    NSData *data = [gameCenterManager buildDataFromGameState:state];
    
    // find participant corresponding to this player (non-local) and opponent (local)
    NSString *localPlayerID = gameCenterManager.localPlayerID;
    GKTurnBasedMatch *currentMatch = gameCenterManager.currentMatch;
    NSUInteger participantIndex = [currentMatch.participants indexOfObjectPassingTest:^BOOL(GKTurnBasedParticipant *obj, NSUInteger idx, BOOL *stop) {
        return ![localPlayerID isEqualToString:obj.playerID];
    }];
    GKTurnBasedParticipant *participant = currentMatch.participants[participantIndex];
    GKTurnBasedParticipant *opponent = currentMatch.participants[1-participantIndex];
    
    void(^completionHandler)(NSError *) = ^(NSError *error) {
        if (error != nil) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            JCSFlipUIErrorEventData *data = [[JCSFlipUIErrorEventData alloc] initWithError:error];
            [nc postNotificationName:JCS_FLIP_UI_ERROR_EVENT_NAME object:self eventData:data];
        }
    };
    
    if (JCSFlipGameStatusIsOver(state.status)) {
        // set outcomes before ending the match
        if (state.status == JCSFlipGameStatusDraw) {
            participant.matchOutcome = GKTurnBasedMatchOutcomeTied;
            opponent.matchOutcome = GKTurnBasedMatchOutcomeTied;
        } else {
            // check if this player (non-local) is player A
            BOOL isPlayerA = state.playerToMove == JCSFlipPlayerSideA;
            if (state.status == JCSFlipGameStatusPlayerAWon) {
                // if we're player A, we won
                participant.matchOutcome = isPlayerA ? GKTurnBasedMatchOutcomeWon : GKTurnBasedMatchOutcomeLost;
                opponent.matchOutcome = isPlayerA ? GKTurnBasedMatchOutcomeLost : GKTurnBasedMatchOutcomeWon;
            } else {
                // if we're player B, we lost
                participant.matchOutcome = isPlayerA ? GKTurnBasedMatchOutcomeLost : GKTurnBasedMatchOutcomeWon;
                opponent.matchOutcome = isPlayerA ? GKTurnBasedMatchOutcomeWon : GKTurnBasedMatchOutcomeLost;
            }
        }
        
        // end the match, updating the match data
        [currentMatch endMatchInTurnWithMatchData:data completionHandler:completionHandler];
    } else {
        // end the turn, updating the match data
        [currentMatch endTurnWithNextParticipants:@[participant] turnTimeout:0 matchData:data completionHandler:completionHandler];
    }
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, player will be notified by game center
}

- (void)cancel {
    // do nothing, there is nothing asynchronous
}

- (NSString *)description {
    return @"(GameCenter Player)";
}

@end
