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

@synthesize name = _name;
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
    
    // find participant corresponding to non-local player (= this player)
    NSString *localPlayerID = gameCenterManager.localPlayerID;
    GKTurnBasedMatch *currentMatch = gameCenterManager.currentMatch;
    NSUInteger participantIndex = [currentMatch.participants indexOfObjectPassingTest:^BOOL(GKTurnBasedParticipant *obj, NSUInteger idx, BOOL *stop) {
        return ![localPlayerID isEqualToString:obj.playerID];
    }];
    GKTurnBasedParticipant *participant = [currentMatch.participants objectAtIndex:participantIndex];
    
    // TODO set outcomes and invoke endMatchInTurnWithMatchData on the match
    
    // end the turn, updating the match data
    [currentMatch endTurnWithNextParticipant:participant matchData:data completionHandler:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, player will be notified by game center
}

@end
