//
//  JCSFlipUIEvents.h
//  HexaFlip
//
//  Created by Christian Schuster on 15.01.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

@class JCSFlipGameState;
@protocol JCSFlipPlayer;

// event names
static NSString *JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME = @"JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME";
static NSString *JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME = @"JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME";
static NSString *JCS_FLIP_UI_BACK_EVENT_NAME = @"JCS_FLIP_UI_BACK_EVENT_NAME";
static NSString *JCS_FLIP_UI_CANCEL_EVENT_NAME = @"JCS_FLIP_UI_CANCEL_EVENT_NAME";
static NSString *JCS_FLIP_UI_PREPARE_GAME_EVENT_NAME = @"JCS_FLIP_UI_PREPARE_GAME_EVENT_NAME";
static NSString *JCS_FLIP_UI_PLAY_GAME_EVENT_NAME = @"JCS_FLIP_UI_PLAY_GAME_EVENT_NAME";
static NSString *JCS_FLIP_UI_EXIT_GAME_EVENT_NAME = @"JCS_FLIP_UI_EXIT_GAME_EVENT_NAME";
static NSString *JCS_FLIP_UI_ERROR_EVENT_NAME = @"JCS_FLIP_UI_ERROR_EVENT_NAME";

@interface NSNotification (JCSFlipUIEvents)

@property (nonatomic, readonly) id eventData;

- (instancetype)initWithName:(NSString *)name object:(id)object eventData:(id)eventData;

+ (instancetype)notificationWithName:(NSString *)name object:(id)object eventData:(id)eventData;

@end

@interface NSNotificationCenter (JCSFlipUIEvents)

- (void)postNotificationName:(NSString *)name object:(id)object eventData:(id)eventData;

@end

// event data for the "prepare game" event
@interface JCSFlipUIPrepareGameEventData : NSObject

@property (nonatomic, readonly) JCSFlipGameState *gameState;
@property (nonatomic, readonly) id<JCSFlipPlayer> playerA;
@property (nonatomic, readonly) id<JCSFlipPlayer> playerB;
@property (nonatomic, readonly) GKTurnBasedMatch *match;
@property (nonatomic, readonly) BOOL animateLastMove;
@property (nonatomic, readonly) BOOL moveInputDisabled;

- (instancetype)initWithGameState:(JCSFlipGameState *)gameState playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled;

// shortcut for events with match=nil, animateLastMove=NO, moveInputDisabled=NO
- (instancetype)initWithGameState:(JCSFlipGameState *)gameState playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB;

@end

// event data for the "exit game" event
@interface JCSFlipUIExitGameEventData : NSObject

@property (nonatomic, readonly) BOOL multiplayer;

- (instancetype)initWithMultiplayer:(BOOL)multiplayer;

@end

// event data for the "error" event
@interface JCSFlipUIErrorEventData : NSObject

@property (nonatomic, readonly) NSError *error;

- (instancetype)initWithError:(NSError *)error;

@end

