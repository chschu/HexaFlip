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
    // notify game center
    NSData *data = [[JCSFlipGameCenterManager sharedInstance] buildDataFromGameState:state];;
    
    // reload match
    NSString *matchID = [JCSFlipGameCenterManager sharedInstance].currentMatchID;
    [GKTurnBasedMatch loadMatchWithID:matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
        if (error != nil) {
            // TODO handle error?
            NSLog(@"%@", error);
        } else {
            // find participant corresponding to non-local player (= this player)
            NSString *localPlayerID = [[JCSFlipGameCenterManager sharedInstance] localPlayerID];
            NSUInteger participantIndex = [match.participants indexOfObjectPassingTest:^BOOL(GKTurnBasedParticipant *obj, NSUInteger idx, BOOL *stop) {
                return ![localPlayerID isEqualToString:obj.playerID];
            }];
            GKTurnBasedParticipant *participant = [match.participants objectAtIndex:participantIndex];
            
            // update the match data
            [match endTurnWithNextParticipant:participant matchData:data completionHandler:nil];
        }
    }];
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, player will be notified by game center
}

@end
