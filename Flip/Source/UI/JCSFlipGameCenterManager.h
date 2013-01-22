//
//  JCSFlipGameCenterManager.h
//  HexaFlip
//
//  Created by Christian Schuster on 18.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

@class JCSFlipGameState;

@protocol JCSFlipMoveInputDelegate;

@interface JCSFlipGameCenterManager : NSObject <GKTurnBasedEventHandlerDelegate>

@property (readonly, nonatomic) BOOL isLocalPlayerAuthenticated;

// the playerID of the local player
@property (nonatomic) NSString *localPlayerID;

// the currently displayed match (nil if not on game screen)
@property (nonatomic) GKTurnBasedMatch *currentMatch;

// the move input delegate to dispatch moves to (nil if not on game screen)
@property (weak, nonatomic) id<JCSFlipMoveInputDelegate> moveInputDelegate;

+ (JCSFlipGameCenterManager *)sharedInstance;

- (void)authenticateLocalPlayer;

- (void)addPlayerAuthenticationObserver:(id)notificationObserver selector:(SEL)notificationSelector;

- (void)removePlayerAuthenticationObserver:(id)notificationObserver;

// build a game state instance from the given match data
// if the match data is nil or empty, a fresh default game state is created
- (JCSFlipGameState *)buildGameStateFromData:(NSData *)data;

- (NSData *)buildDataFromGameState:(JCSFlipGameState *)gameState;


@end
