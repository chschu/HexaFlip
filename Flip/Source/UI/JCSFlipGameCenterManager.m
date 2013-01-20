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
#import "JCSFlipPlayerMoveInputDelegate.h"

@implementation JCSFlipGameCenterManager

@synthesize isLocalPlayerAuthenticated = _isLocalPlayerAuthenticated;
@synthesize localPlayerID = _localPlayerID;
@synthesize currentMatchID = _currentMatchID;
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
        [self addPlayerAuthenticationObserver:self selector:@selector(authenticationChanged:)];
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

- (void)authenticationChanged:(NSNotification *)notification {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    _isLocalPlayerAuthenticated = localPlayer.isAuthenticated;
    _localPlayerID = localPlayer.playerID;
}

- (void)authenticateLocalPlayer {
    // completion is detected by notification
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
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

// handleTurnEventForMatch is called when becomes this player's turn. It may also get called if the player's turn has a timeout and it is about to expire. Note this may also arise from the player accepting an invite from another player. Because of this the app needs to be prepared to handle this even while the player is taking a turn in an existing match.  The boolean indicates whether this event launched or brought to forground the app.
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
    if ([_currentMatchID isEqualToString:match.matchID]) {
        // it's the current match, make the move
        
        // extract last move
        JCSFlipGameState *gameState = [self buildGameStateFromData:match.matchData];
        JCSFlipMove *move = gameState.lastMove;
        
        // notify in main thread
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
            // tell the delegate to make that move
            [_moveInputDelegate inputConfirmedWithMove:move];
        });
        
    }
}

// handleMatchEnded is called when the match has ended.
- (void)handleMatchEnded:(GKTurnBasedMatch *)match {
    // TODO implement
}

@end
