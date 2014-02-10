//
//  JCSFlipUIEvents.m
//  HexaFlip
//
//  Created by Christian Schuster on 15.01.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIEvents.h"

// key where event data is stored in the userInfo of NSNotification
static NSString *JCS_FLIP_UI_EVENT_DATA_KEY = @"JCS_FLIP_UI_EVENT_DATA_KEY";

@implementation NSNotification (JCSFlipUIEvents)

- (instancetype)initWithName:(NSString *)name object:(id)object eventData:(id)eventData {
    return [self initWithName:name object:object userInfo:[NSDictionary dictionaryWithObject:eventData forKey:JCS_FLIP_UI_EVENT_DATA_KEY]];
}

+ (instancetype)notificationWithName:(NSString *)name object:(id)object eventData:(id)eventData {
    return [[self alloc] initWithName:name object:object eventData:eventData];
}

- (id)eventData {
    return [self.userInfo objectForKey:JCS_FLIP_UI_EVENT_DATA_KEY];
}

@end

@implementation NSNotificationCenter (JCSFlipUIEvents)

- (void)postNotificationName:(NSString *)name object:(id)object eventData:(id)eventData {
    [self postNotification:[NSNotification notificationWithName:name object:object eventData:eventData]];
}

@end

@implementation JCSFlipUIPrepareGameEventData

- (instancetype)initWithGameState:(JCSFlipGameState *)gameState playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB {
    return [self initWithGameState:gameState playerA:playerA playerB:playerB match:nil animateLastMove:NO moveInputDisabled:NO];
}

- (instancetype)initWithGameState:(JCSFlipGameState *)gameState playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled {
    if (self = [super init]) {
        _gameState = gameState;
        _playerA = playerA;
        _playerB = playerB;
        _match = match;
        _animateLastMove = animateLastMove;
        _moveInputDisabled = moveInputDisabled;
    }
    return self;
}

@end

@implementation JCSFlipUIExitGameEventData

- (instancetype)initWithMultiplayer:(BOOL)multiplayer {
    if (self = [super init]) {
        _multiplayer = multiplayer;
    }
    return self;
}

@end

@implementation JCSFlipUIErrorEventData

- (instancetype)initWithError:(NSError *)error {
    if (self = [super init]) {
        _error = error;
    }
    return self;
}

@end