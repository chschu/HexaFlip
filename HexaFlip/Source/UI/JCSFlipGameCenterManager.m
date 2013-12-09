//
//  JCSFlipGameCenterManager.m
//  HexaFlip
//
//  Created by Christian Schuster on 18.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameCenterManager.h"
#import "JCSFlipGameState.h"
#import "JCSFlipMove.h"
#import "JCSFlipMoveInputDelegate.h"
#import "JCSFlipGameCenterInviteDelegate.h"

@implementation JCSFlipGameCenterManager

@synthesize currentMatch = _currentMatch;
@synthesize moveInputDelegate = _moveInputDelegate;
@synthesize gameCenterInviteDelegate = _gameCenterInviteDelegate;

static JCSFlipGameCenterManager *_sharedInstance = nil;

+ (JCSFlipGameCenterManager *)sharedInstance {
    @synchronized(self) {
        if (_sharedInstance != nil) {
            return _sharedInstance;
        }
        return [[self alloc] init];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        NSAssert(_sharedInstance == nil, @"second allocation of singleton not allowed");
        _sharedInstance = [super allocWithZone:zone];
        return _sharedInstance;
    }
}

- (void)addPlayerAuthenticationObserver:(id)notificationObserver selector:(SEL)notificationSelector {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:notificationObserver
           selector:notificationSelector
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
}

- (void)removePlayerAuthenticationObserver:(id)notificationObserver {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:notificationObserver
                  name:GKPlayerAuthenticationDidChangeNotificationName
                object:nil];
    
}

- (void)authenticateLocalPlayer {
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error == nil) {
            [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
        }
    }];
}

- (BOOL)isLocalPlayerAuthenticated {
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

- (NSString *)localPlayerID {
    return [GKLocalPlayer localPlayer].playerID;
}

- (NSData *)buildDataFromGameState:(JCSFlipGameState *)gameState {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    // the last move is required in the game state (move is replayed during a "live" match)
    [gameState encodeWithCoder:coder maxMoves:1];
    [coder finishEncoding];
    return [data copy];
}

- (JCSFlipGameState *)buildGameStateFromMatch:(GKTurnBasedMatch *)match {
    JCSFlipGameState *result;
    NSData *data = match.matchData;
    if (data == nil || data.length == 0) {
        // determine which player should make the first move (should be player A/index 0, but don't rely on that)
        JCSFlipPlayerSide playerToMove = [match.participants indexOfObject:match.currentParticipant] == 0 ? JCSFlipPlayerSideA : JCSFlipPlayerSideB;
        // create new game state
        result = [[JCSFlipGameState alloc] initDefaultWithSize:5 playerToMove:playerToMove];
    } else {
        // deserialize existing game state
        NSKeyedUnarchiver *coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        result = [[JCSFlipGameState alloc] initWithCoder:coder];
    }
    return result;
}

#pragma mark GKTurnBasedEventHandlerDelegate methods

// If Game Center initiates a match the developer should create a GKTurnBasedMatch from playersToInvite and present a GKTurnbasedMatchmakerViewController.
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    [_gameCenterInviteDelegate presentInviteWithPlayers:playersToInvite];
}

// handleTurnEventForMatch is called when becomes this player's turn. It may also get called if the player's turn has a timeout and it is about to expire. Note this may also arise from the player accepting an invite from another player. Because of this the app needs to be prepared to handle this even while the player is taking a turn in an existing match.
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
    // only react if the event is for the current match
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        // update the current match ("match" is a new instance holding the updated data)
        _currentMatch = match;
        
        // perform move input for last move of game state
        JCSFlipGameState *gameState = [self buildGameStateFromMatch:_currentMatch];
        [gameState.lastMove performInputWithMoveInputDelegate:_moveInputDelegate];
    }
}

// handleMatchEnded is called when the match has ended.
- (void)handleMatchEnded:(GKTurnBasedMatch *)match {
    // only react if the event is for the current match
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        // update the current match ("match" is a new instance holding the updated data)
        _currentMatch = match;
        
        // perform move input for last move of game state, except if the game ended "non-naturally" (opponent quit)
        JCSFlipGameState *gameState = [self buildGameStateFromMatch:_currentMatch];
        if (JCSFlipGameStatusIsOver(gameState.status)) {
            [gameState.lastMove performInputWithMoveInputDelegate:_moveInputDelegate];
        }
    }
}

@end
