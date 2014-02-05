//
//  JCSFlipUIScene.m
//  HexaFlip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipUIScene.h"
#import "JCSFlipUIGameScreen.h"
#import "JCSFlipUIMainMenuScreen.h"
#import "JCSFlipUIPlayerMenuScreen.h"
#import "JCSFlipUIMultiplayerScreen.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipGameState.h"
#import "JCSFlipGameCenterManager.h"
#import "JCSFlipUIEvents.h"

@implementation JCSFlipUIScene {
    // global parallax node
    CCParallaxNode *_parallax;
    
    // main menu screen
    JCSFlipUIMainMenuScreen *_mainMenuScreen;
    
    // player selectio menu screen
    JCSFlipUIPlayerMenuScreen *_playerMenuScreen;
    
    // game screen
    JCSFlipUIGameScreen *_gameScreen;
    
    // multiplayer pseudo-screen
    JCSFlipUIMultiplayerScreen *_multiplayerScreen;
    
    // currently active screen
    id<JCSFlipUIScreenWithPoint> _activeScreen;
    
    // the local player's playerId, used to detect when the local player has logged out or changed
    NSString *_playerId;
    
    // flag indicating if a screen switch is in progress
    BOOL _switching;
}

// this could be done in -init, but then the scene is rendered in portrait mode, which breaks the layout
- (void)onEnter {
    [super onEnter];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _parallax = [CCParallaxNode node];
    
    // background tile map
    CCNode *backgroundTileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"background.tmx"];
    [_parallax addChild:backgroundTileMap z:0 parallaxRatio:ccp(1,1) positionOffset:ccp(-0.5*winSize.width,-0.5*winSize.height)];
    
    // main menu screen
    _mainMenuScreen = [JCSFlipUIMainMenuScreen node];
    [self addScreen:_mainMenuScreen atScreenPoint:ccp(0,2) z:1];
    
    // player selection menu screen
    _playerMenuScreen = [JCSFlipUIPlayerMenuScreen node];
    [self addScreen:_playerMenuScreen atScreenPoint:ccp(1,3) z:1];
    
    // game screen
    _gameScreen = [JCSFlipUIGameScreen node];
    [self addScreen:_gameScreen atScreenPoint:ccp(1,1) z:1];
    
    // multiplayer pseudo-screen
    _multiplayerScreen = [JCSFlipUIMultiplayerScreen node];
    [self addScreen:_multiplayerScreen atScreenPoint:_gameScreen.screenPoint z:1];
    
    [self addChild:_parallax];
    
    // register for the game center authentication
    [[JCSFlipGameCenterManager sharedInstance] addPlayerAuthenticationObserver:self selector:@selector(playerAuthenticationDidChange:)];
    
    // set this instance as delegate for game center invites
    [JCSFlipGameCenterManager sharedInstance].gameCenterInviteDelegate = self;
    
    // register notification event handlers
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showPlayerMenuScreen:) name:JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME object:_mainMenuScreen];
    [nc addObserver:self selector:@selector(showMultiPlayerScreen:) name:JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME object:_mainMenuScreen];
    [nc addObserver:self selector:@selector(showMainMenuScreen:) name:JCS_FLIP_UI_BACK_EVENT_NAME object:_playerMenuScreen];
    [nc addObserver:self selector:@selector(showMainMenuScreen:) name:JCS_FLIP_UI_CANCEL_EVENT_NAME object:_multiplayerScreen];
    [nc addObserver:self selector:@selector(startGame:) name:JCS_FLIP_UI_PLAY_GAME_EVENT_NAME object:nil];
    [nc addObserver:self selector:@selector(exitGame:) name:JCS_FLIP_UI_EXIT_GAME_EVENT_NAME object:_gameScreen];
    [nc addObserver:self selector:@selector(showError:) name:JCS_FLIP_UI_ERROR_EVENT_NAME object:nil];
    
    // enable the main menu screen
    [self switchToScreen:_mainMenuScreen animated:NO];
}

- (void)onExit {
    [super onExit];
    
    // unregister notification event handlers
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME object:nil];
    [nc removeObserver:self name:JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME object:nil];
    [nc removeObserver:self name:JCS_FLIP_UI_BACK_EVENT_NAME object:nil];
    [nc removeObserver:self name:JCS_FLIP_UI_CANCEL_EVENT_NAME object:nil];
    [nc removeObserver:self name:JCS_FLIP_UI_PLAY_GAME_EVENT_NAME object:nil];
    [nc removeObserver:self name:JCS_FLIP_UI_EXIT_GAME_EVENT_NAME object:nil];
    [nc removeObserver:self name:JCS_FLIP_UI_ERROR_EVENT_NAME object:nil];
    
    [[JCSFlipGameCenterManager sharedInstance] removePlayerAuthenticationObserver:self];
    
    // remove delegate registration
    [JCSFlipGameCenterManager sharedInstance].gameCenterInviteDelegate = nil;
}

- (void)playerAuthenticationDidChange:(NSNotification *)notification {
    JCSFlipGameCenterManager *manager = [JCSFlipGameCenterManager sharedInstance];
    // leave the active screen if it wants to, and the previous player has logged out or changed
    if (_activeScreen.leaveScreenWhenPlayerLoggedOut && _playerId != nil && !(manager.isLocalPlayerAuthenticated && [_playerId isEqualToString:manager.localPlayerID])) {
        NSLog(@"local player has logged out or changed, switching back to main menu screen");
        [self switchToScreen:_mainMenuScreen animated:YES];
    }
    
    // update the stored player id
    _playerId = manager.localPlayerID;
}

- (void)addScreen:(id<JCSFlipUIScreenWithPoint>)screen atScreenPoint:(CGPoint)screenPoint z:(NSInteger)z {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint winSizePoint = ccpFromSize(winSize);
    
    screen.screenPoint = screenPoint;
    [_parallax addChild:screen z:z parallaxRatio:ccp(1,1) positionOffset:ccpCompMult(screenPoint,winSizePoint)];
}

// disable the currently active screen, activate the given screen, and enable it
// for screens with point (conforming to protocol JCSFlipUIScreenWithPoint), the screen is made visible
// for screens without point, the "animated" parameter is ignored, because no animation is required
- (void)switchToScreen:(id<JCSFlipUIScreenWithPoint>)screen animated:(BOOL)animated {
    @synchronized (self) {
        // ignore switching requests if a switch is in progress
        if (_switching) {
            return;
        }
        _switching = YES;
    }
    
    // create local references to avoid retaining self in the blocks below
    CCParallaxNode *parallax = _parallax;
    
    // disable old screen
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint winSizePoint = ccpFromSize(winSize);
    
    CGPoint targetPosition = ccpCompMult(screen.screenPoint,ccpMult(winSizePoint,-1));
    
    id<JCSFlipUIScreenWithPoint> oldActiveScreen = _activeScreen;
    
    void(^willSwitchBlock)() = ^{
        [CCDirector sharedDirector].touchDispatcher.dispatchEvents = NO;
        if ([oldActiveScreen respondsToSelector:@selector(willDeactivateScreen)]) {
            [oldActiveScreen willDeactivateScreen];
        }
        if ([screen respondsToSelector:@selector(willActivateScreen)]) {
            [screen willActivateScreen];
        }
        _activeScreen = nil;
    };
    
    void(^didSwitchBlock)() = ^{
        _activeScreen = screen;
        if ([oldActiveScreen respondsToSelector:@selector(didDeactivateScreen)]) {
            [oldActiveScreen didDeactivateScreen];
        }
        if ([screen respondsToSelector:@selector(didActivateScreen)]) {
            [screen didActivateScreen];
        }
        [CCDirector sharedDirector].touchDispatcher.dispatchEvents = YES;
        @synchronized (self) {
            _switching = NO;
        }
    };
    
    if (animated) {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        // collect action to notify screens that switch is about to happen
        [actions addObject:[CCCallBlock actionWithBlock:willSwitchBlock]];
        
        // collect action to move the parallax node
        if (!CGPointEqualToPoint(targetPosition, parallax.position)) {
            CCAction *moveToNewScreen = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:targetPosition]];
            [actions addObject:moveToNewScreen];
        }
        
        // collect action to notify screens that switch is about to happen
        [actions addObject:[CCCallBlock actionWithBlock:didSwitchBlock]];
        
        // start the collected actions
        [parallax runAction:[CCSequence actionWithArray:actions]];
    } else {
        // apply immediately
        willSwitchBlock();
        parallax.position = targetPosition;
        didSwitchBlock();
    }
}

#pragma mark notification event handlers

- (void)showMainMenuScreen:(NSNotification *)notification {
    [self switchToScreen:_mainMenuScreen animated:YES];
}

- (void)showPlayerMenuScreen:(NSNotification *)notification {
    [self switchToScreen:_playerMenuScreen animated:YES];
}

- (void)showMultiPlayerScreen:(NSNotification *)notification {
    _multiplayerScreen.playersToInvite = nil;
    [self switchToScreen:_multiplayerScreen animated:YES];
}

- (void)startGame:(NSNotification *)notification {
    // prepare game screen using the event data
    JCSFlipUIPlayGameEventData *data = [notification.userInfo objectForKey:JCS_FLIP_UI_EVENT_DATA_KEY];
    [_gameScreen prepareGameWithState:data->gameState playerA:data->playerA playerB:data->playerB match:data->match animateLastMove:data->animateLastMove moveInputDisabled:data->moveInputDisabled];
    
    [self switchToScreen:_gameScreen animated:YES];
}

- (void)exitGame:(NSNotification *)notification {
    // switch to screen depending on notification data
    JCSFlipUIExitGameEventData *data = [notification.userInfo objectForKey:JCS_FLIP_UI_EVENT_DATA_KEY];
    
    if (data->multiplayer) {
        [self switchToScreen:_multiplayerScreen animated:YES];
    } else {
        [self switchToScreen:_mainMenuScreen animated:YES];
    }
}

- (void)showError:(NSNotification *)notification {
    // switch to main menu screen
    [self switchToScreen:_mainMenuScreen animated:YES];
    
    // extract and display the error
    JCSFlipUIErrorEventData *data = [notification.userInfo objectForKey:JCS_FLIP_UI_EVENT_DATA_KEY];
    NSError *error = data->error;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark JCSFlipGameCenterInviteDelegate methods

- (void)presentInviteWithPlayers:(NSArray *)playersToInvite {
    _multiplayerScreen.playersToInvite = playersToInvite;
    [self switchToScreen:_multiplayerScreen animated:YES];
}

@end
