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
#import "JCSFlipUIEvents.h"

#import "cocos2d.h"

@implementation JCSFlipGameCenterManager

static JCSFlipGameCenterManager *_sharedInstance = nil;

+ (JCSFlipGameCenterManager *)sharedInstance {
    @synchronized(self) {
        if (_sharedInstance != nil) {
            return _sharedInstance;
        }
        return [[self alloc] init];
    }
}

+ (instancetype)allocWithZone:(NSZone *)zone {
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
    [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (error == nil) {
            if (viewController != nil) {
                // no authenticated player
                [[CCDirector sharedDirector] presentViewController:viewController animated:YES completion:nil];
            } else {
                // player authentication completed
                [[GKLocalPlayer localPlayer] registerListener:self];
            }
        }
    };
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
        result = [[JCSFlipGameState alloc] initWithSize:5 playerToMove:playerToMove];
    } else {
        // deserialize existing game state
        NSKeyedUnarchiver *coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        result = [[JCSFlipGameState alloc] initWithCoder:coder];
    }
    return result;
}

#pragma mark GKTurnBasedEventListener methods

- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite {
    [_gameCenterInviteDelegate presentInviteWithPlayers:playerIDsToInvite];
}

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    // only react if the event is for the current match
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        // update the current match ("match" is a new instance holding the updated data)
        _currentMatch = match;
        
        // perform move input for last move of game state
        JCSFlipGameState *gameState = [self buildGameStateFromMatch:_currentMatch];
        [gameState.lastMove performInputWithMoveInputDelegate:_moveInputDelegate];
    } else if (didBecomeActive) {
        // app was activated for the event, go to the multiplayer screen immediately
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME object:self];
    }
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match {
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
