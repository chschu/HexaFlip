//
//  JCSFlipUIMultiplayerScreen.m
//  Flip
//
//  Created by Christian Schuster on 15.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipUIMultiplayerScreen.h"
#import "JCSFlipUIMultiplayerScreenDelegate.h"
#import "JCSFlipGameState.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerGameCenter.h"

@implementation JCSFlipUIMultiplayerScreen

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;

- (void)setScreenEnabled:(BOOL)screenEnabled {
    _screenEnabled = screenEnabled;
    if (_screenEnabled) {
        GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
        matchRequest.minPlayers = 2;
        matchRequest.maxPlayers = 2;
        
        GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
        mmvc.turnBasedMatchmakerDelegate = self;
        [[CCDirector sharedDirector] presentModalViewController:mmvc animated:YES];
    }
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate methods

// The user has cancelled
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    [viewController dismissModalViewControllerAnimated:YES];
    [_delegate matchMakingCancelledFromMultiplayerScreen:self];
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [viewController dismissModalViewControllerAnimated:YES];
    [_delegate matchMakingFailedWithError:error fromMultiplayerScreen:self];
}

// A turned-based match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    [viewController dismissModalViewControllerAnimated:YES];
    
    // todo notify delegate to prepare and scroll to game screen

    // extract the game state from the match, or create a new one
    JCSFlipGameState *gameState;
    if (match.matchData == nil || match.matchData.length == 0) {
        gameState = [[JCSFlipGameState alloc] initDefaultWithSize:5];
    } else {
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:match.matchData];
        gameState = [[JCSFlipGameState alloc] initWithCoder:decoder];
    }

    // determine remote participant
    NSString *localPlayerId = [GKLocalPlayer localPlayer].playerID;
    NSUInteger remoteParticipantIndex = [match.participants indexOfObjectPassingTest:^BOOL(GKTurnBasedParticipant *obj, NSUInteger idx, BOOL *stop) {
        return ![obj.playerID isEqualToString:localPlayerId];
    }];
    GKTurnBasedParticipant *remoteParticipant = [match.participants objectAtIndex:remoteParticipantIndex];

    // check if the local player can make his move
    BOOL localPlayerToMove = [match.currentParticipant.playerID isEqualToString:localPlayerId];
    
    // initialize the players
    id<JCSFlipPlayer> localPlayer = [JCSFlipPlayerLocal playerWithName:@"dummy name"];
    id<JCSFlipPlayer> remotePlayer = [JCSFlipPlayerGameCenter playerWithMatch:match participant:remoteParticipant];
    
    id<JCSFlipPlayer> playerA;
    id<JCSFlipPlayer> playerB;
    if (gameState.status == JCSFlipGameStatusPlayerAToMove) {
        playerA = localPlayerToMove ? localPlayer : remotePlayer;
        playerB = localPlayerToMove ? remotePlayer : localPlayer;
    } else if (gameState.status == JCSFlipGameStatusPlayerBToMove) {
        playerA = localPlayerToMove ? remotePlayer : localPlayer;
        playerB = localPlayerToMove ? localPlayer : remotePlayer;
    } else {
        // game is over, use nil players
        playerA = nil;
        playerB = nil;
    }

    [_delegate switchToGameWithPlayerA:playerA playerB:playerB gameState:gameState fromMultiplayerScreen:self];
}

// Called when a users chooses to quit a match and that player has the current turn.  The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.  They can also update matchOutcome for other players as appropriate.
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    // determine next participant
    NSUInteger currentParticipantIndex = [match.participants indexOfObject:match.currentParticipant];
    NSUInteger nextParticipantIndex = 1-currentParticipantIndex;
    GKTurnBasedParticipant *nextParticipant = [match.participants objectAtIndex:nextParticipantIndex];

    // if the participant quits in turn, the other participant wins
    match.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeQuit;
    nextParticipant.matchOutcome = GKTurnBasedMatchOutcomeWon;

    // extract the match data
    JCSFlipGameState *gameState;
    if (match.matchData == nil || match.matchData.length == 0) {
        gameState = [[JCSFlipGameState alloc] initDefaultWithSize:5];
    } else {
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:match.matchData];
        gameState = [[JCSFlipGameState alloc] initWithCoder:decoder];
    }
    
    // resign the game
    [gameState resign];
    
    // build the match data to send
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [gameState encodeWithCoder:coder includeMoveStack:YES];
    [coder finishEncoding];
    
    // end the match
    [match endMatchInTurnWithMatchData:data completionHandler:nil];
}

@end
