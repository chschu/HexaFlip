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

// key where event data is stored in the userInfo of NSNotification
static NSString *JCS_FLIP_UI_EVENT_DATA_KEY = @"JCS_FLIP_UI_EVENT_DATA_KEY";

// event names
static NSString *JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME = @"JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME";
static NSString *JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME = @"JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME";
static NSString *JCS_FLIP_UI_BACK_EVENT_NAME = @"JCS_FLIP_UI_BACK_EVENT_NAME";
static NSString *JCS_FLIP_UI_CANCEL_EVENT_NAME = @"JCS_FLIP_UI_CANCEL_EVENT_NAME";
static NSString *JCS_FLIP_UI_PLAY_GAME_EVENT_NAME = @"JCS_FLIP_UI_PLAY_GAME_EVENT_NAME";
static NSString *JCS_FLIP_UI_EXIT_GAME_EVENT_NAME = @"JCS_FLIP_UI_EXIT_GAME_EVENT_NAME";
static NSString *JCS_FLIP_UI_ERROR_EVENT_NAME = @"JCS_FLIP_UI_ERROR_EVENT_NAME";

// event data for the "play game" event
@interface JCSFlipUIPlayGameEventData : NSObject {
@public
    JCSFlipGameState *gameState;
    id<JCSFlipPlayer> playerA;
    id<JCSFlipPlayer> playerB;
    GKTurnBasedMatch *match;
    BOOL animateLastMove;
    BOOL moveInputDisabled;
}
@end

// event data for the "exit game" event
@interface JCSFlipUIExitGameEventData : NSObject {
@public
    BOOL multiplayer;
}
@end

// event data for the "error" event
@interface JCSFlipUIErrorEventData : NSObject {
@public
    NSError *error;
}
@end

