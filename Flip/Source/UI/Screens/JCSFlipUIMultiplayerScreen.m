//
//  JCSFlipUIMultiplayerScreen.m
//  HexaFlip
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
#import "JCSFlipGameCenterManager.h"

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

    // extract the game state from the match, or create a new one
    JCSFlipGameCenterManager *gameCenterManager = [JCSFlipGameCenterManager sharedInstance];
    JCSFlipGameState *gameState = [gameCenterManager buildGameStateFromData:match.matchData];
    
    // determine playerID of remote participant
    NSString *localPlayerID = [gameCenterManager localPlayerID];

    // check if the local player can make his move
    BOOL localPlayerToMove = [match.currentParticipant.playerID isEqualToString:localPlayerID];

    // determine if player A is local or remote
    BOOL playerAIsLocal = (localPlayerToMove == (gameState.playerToMove == JCSFlipPlayerToMoveA));
    
    // initialize the players
    id<JCSFlipPlayer> localPlayer = [JCSFlipPlayerLocal player];
    id<JCSFlipPlayer> remotePlayer = [JCSFlipPlayerGameCenter player];
    id<JCSFlipPlayer> playerA = playerAIsLocal ? localPlayer : remotePlayer;
    id<JCSFlipPlayer> playerB = playerAIsLocal ? remotePlayer : localPlayer;

    [_delegate switchToGameWithPlayerA:playerA playerB:playerB gameState:gameState match:match fromMultiplayerScreen:self];
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
    JCSFlipGameState *gameState =[[JCSFlipGameCenterManager sharedInstance] buildGameStateFromData:match.matchData];
    
    // build the match data to send
    NSData *data = [[JCSFlipGameCenterManager sharedInstance] buildDataFromGameState:gameState];
    
    // end the match
    [match endMatchInTurnWithMatchData:data completionHandler:nil];
}

@end
