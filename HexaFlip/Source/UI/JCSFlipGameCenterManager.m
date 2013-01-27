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

@implementation JCSFlipGameCenterManager

@synthesize currentMatch = _currentMatch;
@synthesize moveInputDelegate = _moveInputDelegate;

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

- (id)init {
    if (self = [super init]) {
        [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
    }
    return self;
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
        if (error != nil) {
            // TODO handle error
            NSLog(@"%@", error);
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

- (JCSFlipGameState *)buildGameStateFromData:(NSData *)data {
    JCSFlipGameState *result;
    if (data == nil || data.length == 0) {
        result = [[JCSFlipGameState alloc] initDefaultWithSize:5];
    } else {
        NSKeyedUnarchiver *coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        result = [[JCSFlipGameState alloc] initWithCoder:coder];
    }
    return result;
}

#pragma mark GKTurnBasedEventHandlerDelegate methods

// If Game Center initiates a match the developer should create a GKTurnBasedMatch from playersToInvite and present a GKTurnbasedMatchmakerViewController.
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    // TODO implement
}

- (void)inputMove:(JCSFlipMove *)move {
    // perform move input
    // TODO we have the exact same thing in the AI player class - refactor!
    double delay = 0;
    if (!move.skip) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [_moveInputDelegate inputSelectedStartRow:move.startRow startColumn:move.startColumn];
        });
        delay += 0.25;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [_moveInputDelegate inputSelectedDirection:move.direction startRow:move.startRow startColumn:move.startColumn];
        });
        delay += 0.25;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [_moveInputDelegate inputClearedDirection:move.direction startRow:move.startRow startColumn:move.startColumn];
            [_moveInputDelegate inputClearedStartRow:move.startRow startColumn:move.startColumn];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [_moveInputDelegate inputConfirmedWithMove:move];
    });
}

// handleTurnEventForMatch is called when becomes this player's turn. It may also get called if the player's turn has a timeout and it is about to expire. Note this may also arise from the player accepting an invite from another player. Because of this the app needs to be prepared to handle this even while the player is taking a turn in an existing match.
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
    // only react if the event is for the current match
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        // update the current match ("match" is a new instance holding the updated data)
        _currentMatch = match;
        
        // perform move input for last move of game state
        JCSFlipGameState *gameState = [self buildGameStateFromData:_currentMatch.matchData];
        [self inputMove:gameState.lastMove];
    }
}

// handleMatchEnded is called when the match has ended.
- (void)handleMatchEnded:(GKTurnBasedMatch *)match {
    // only react if the event is for the current match
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        // update the current match ("match" is a new instance holding the updated data)
        _currentMatch = match;
        
        // perform move input for last move of game state, except if the game ended "non-naturally" (opponent quit)
        JCSFlipGameState *gameState = [self buildGameStateFromData:_currentMatch.matchData];
        if (JCSFlipGameStatusIsOver(gameState.status)) {
            [self inputMove:gameState.lastMove];
        }
    }
}

@end
