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

@implementation JCSFlipUIMultiplayerScreen {
    GKTurnBasedMatchmakerViewController *_mmvc;
}

@synthesize delegate = _delegate;
@synthesize playersToInvite = _playersToInvite;

- (void)setScreenEnabled:(BOOL)screenEnabled completion:(void(^)())completion {
    _screenEnabled = screenEnabled;
    if (screenEnabled) {
        GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
        matchRequest.minPlayers = 2;
        matchRequest.maxPlayers = 2;
        matchRequest.playersToInvite = _playersToInvite;
        
        _mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
        _mmvc.turnBasedMatchmakerDelegate = self;
        // don't show existing matches when inviting
        _mmvc.showExistingMatches = (_playersToInvite == nil);
        [[CCDirector sharedDirector] presentViewController:_mmvc animated:YES completion:completion];
    } else {
        [_mmvc dismissViewControllerAnimated:YES completion:completion];
        _mmvc = nil;
    }
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate methods

// The user has cancelled
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    [_delegate matchMakingCancelledFromMultiplayerScreen:self];
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [_delegate matchMakingFailedWithError:error fromMultiplayerScreen:self];
}

// A turned-based match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
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
    
    // prepare the game, but don't start it yet (to avoid animation overlap)
    // animate the last move only if it's the local player's turn
    [_delegate prepareGameWithPlayerA:playerA playerB:playerB gameState:gameState match:match animateLastMove:localPlayerToMove fromMultiplayerScreen:self];
    
    // start the game
    [_delegate startPreparedGameFromMultiplayerScreen:self];
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
