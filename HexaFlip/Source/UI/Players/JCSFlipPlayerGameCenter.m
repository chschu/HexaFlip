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


#import "cocos2d.h"

@implementation JCSFlipPlayerGameCenter

@synthesize moveInputDelegate = _moveInputDelegate;

+ (id)player {
    return [[self alloc] init];
}

- (BOOL)localControls {
    return NO;
}

- (void)opponentDidMakeMove:(JCSFlipGameState *)state {
    JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
    
    // generate data for game center
    NSData *data = [gameCenterManager buildDataFromGameState:state];;
    
    // find participant corresponding to this player (non-local) and opponent (local)
    NSString *localPlayerID = gameCenterManager.localPlayerID;
    GKTurnBasedMatch *currentMatch = gameCenterManager.currentMatch;
    NSUInteger participantIndex = [currentMatch.participants indexOfObjectPassingTest:^BOOL(GKTurnBasedParticipant *obj, NSUInteger idx, BOOL *stop) {
        return ![localPlayerID isEqualToString:obj.playerID];
    }];
    GKTurnBasedParticipant *participant = [currentMatch.participants objectAtIndex:participantIndex];
    GKTurnBasedParticipant *opponent = [currentMatch.participants objectAtIndex:1-participantIndex];
    
    if (JCSFlipGameStatusIsOver(state.status)) {
        // set outcomes before ending the match
        if (state.status == JCSFlipGameStatusDraw) {
            participant.matchOutcome = GKTurnBasedMatchOutcomeTied;
            opponent.matchOutcome = GKTurnBasedMatchOutcomeTied;
        } else {
            // check if this player (non-local) is player A
            BOOL isPlayerA = state.playerToMove == JCSFlipPlayerToMoveA;
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
        [currentMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
            if (error != nil) {
                // TODO we need to retry or leave the game screen in this case
                NSLog(@"%@", error);
            }
        }];
        
    } else {
        // end the turn, updating the match data
        [currentMatch endTurnWithNextParticipant:participant matchData:data completionHandler:^(NSError *error) {
            if (error != nil) {
                // TODO we need to retry or leave the game screen in this case
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, player will be notified by game center
}

@end
