//
//  JCSFlipUIEvents.m
//  HexaFlip
//
//  Created by Christian Schuster on 15.01.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIEvents.h"

@implementation JCSFlipUIPlayGameEventData

- (id)initWithGameState:(JCSFlipGameState *)gameState playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB {
    return [self initWithGameState:gameState playerA:playerA playerB:playerB match:nil animateLastMove:NO moveInputDisabled:NO];
}

- (id)initWithGameState:(JCSFlipGameState *)gameState playerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled {
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

- (id)initWithMultiplayer:(BOOL)multiplayer {
    if (self = [super init]) {
        _multiplayer = multiplayer;
    }
    return self;
}

@end

@implementation JCSFlipUIErrorEventData

- (id)initWithError:(NSError *)error {
    if (self = [super init]) {
        _error = error;
    }
    return self;
}

@end