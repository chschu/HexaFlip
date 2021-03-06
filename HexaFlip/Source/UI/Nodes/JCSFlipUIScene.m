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
    // this is the only screen with screenEnabled == YES
    id<JCSFlipUIScreenWithPoint> _activeScreen;
    
    // the local player's playerId, used to detect when the local player has logged out or changed
    NSString *_playerId;
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
    _mainMenuScreen.delegate = self;
    [self addScreen:_mainMenuScreen atScreenPoint:ccp(0,2) z:1];
    
    // player selection menu screen
    _playerMenuScreen = [JCSFlipUIPlayerMenuScreen node];
    _playerMenuScreen.delegate = self;
    [self addScreen:_playerMenuScreen atScreenPoint:ccp(1,3) z:1];
    
    // game screen
    _gameScreen = [JCSFlipUIGameScreen node];
    _gameScreen.delegate = self;
    [self addScreen:_gameScreen atScreenPoint:ccp(1,1) z:1];
    
    // multiplayer pseudo-screen
    _multiplayerScreen = [JCSFlipUIMultiplayerScreen node];
    _multiplayerScreen.delegate = self;
    [self addScreen:_multiplayerScreen atScreenPoint:_gameScreen.screenPoint z:1];
    
    [self addChild:_parallax];
    
    // register for the game center authentication
    [[JCSFlipGameCenterManager sharedInstance] addPlayerAuthenticationObserver:self selector:@selector(playerAuthenticationDidChange:)];
    
    // set this instance as delegate for game center invites
    [JCSFlipGameCenterManager sharedInstance].gameCenterInviteDelegate = self;
    
    // enable the main menu screen
    [self switchToScreen:_mainMenuScreen animated:NO];
}

- (void)onExit {
    [super onExit];
    
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
// the completion block is called after the new screen has been enabled
- (void)switchToScreen:(id<JCSFlipUIScreenWithPoint>)screen animated:(BOOL)animated completion:(void(^)())completion {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    // create local references to avoid retaining self in the blocks below
    CCParallaxNode *parallax = _parallax;
    JCSFlipUIScene *scene = self;
    
    // disable old screen
    [self setScreen:_activeScreen enabled:NO completion:^{
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGPoint winSizePoint = ccpFromSize(winSize);
        
        CGPoint targetPosition = ccpCompMult(screen.screenPoint,ccpMult(winSizePoint,-1));
        
        if (animated) {
            if (!CGPointEqualToPoint(targetPosition, parallax.position)) {
                CCAction *moveToNewScreen = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:targetPosition]];
                [actions addObject:moveToNewScreen];
            }
        
            // action to enable the new screen
            CCCallBlock *enableNewScreen = [CCCallBlock actionWithBlock:^{
                [scene setScreen:screen enabled:YES completion:completion];
            }];
            [actions addObject:enableNewScreen];
        
            // start the collected actions
            [parallax runAction:[CCSequence actionWithArray:actions]];
        } else {
            // apply immediately
            parallax.position = targetPosition;
            [scene setScreen:screen enabled:YES completion:completion];
        }
    }];
}

- (void)setScreen:(id<JCSFlipUIScreenWithPoint>)screen enabled:(BOOL)enabled completion:(void(^)())completion {
    if (screen != nil) {
        id<JCSFlipUIScreenWithPoint> newScreen = screen;
        [screen setScreenEnabled:enabled completion:^{
            if (enabled) {
                _activeScreen = newScreen;
            } else {
                _activeScreen = nil;
            }
            if (completion != nil) {
                completion();
            }
        }];
    } else {
        if (completion != nil) {
            completion();
        }
    }
}

// convenience method to switch the screen without a completion block
- (void)switchToScreen:(id<JCSFlipUIScreenWithPoint>)screen animated:(BOOL)animated {
    [self switchToScreen:screen animated:animated completion:nil];
}

#pragma mark JCSFlipUIMainMenuScreenDelegate methods

- (void)playSingleFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_playerMenuScreen animated:YES];
    }
}

- (void)playMultiFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen {
    if (screen.screenEnabled) {
        _multiplayerScreen.playersToInvite = nil;
        [self switchToScreen:_multiplayerScreen animated:YES];
    }
}

#pragma mark JCSFlipUIPlayerMenuScreenDelegate methods

- (void)startGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB fromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    if (screen.screenEnabled) {
        [_gameScreen prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5 playerToMove:JCSFlipPlayerSideA] playerA:playerA playerB:playerB match:nil animateLastMove:NO moveInputDisabled:NO];
        [self switchToScreen:_gameScreen animated:YES completion:^{
            [_gameScreen startGame];
        }];
    }
}

- (void)backFromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_mainMenuScreen animated:YES];
    }
}

#pragma mark JCSFlipUIGameScreenDelegate methods

- (void)exitGameMultiplayer:(BOOL)multiplayer fromGameScreen:(JCSFlipUIGameScreen *)screen {
    if (screen.screenEnabled) {
        if (multiplayer) {
            _multiplayerScreen.playersToInvite = nil;
            [self switchToScreen:_multiplayerScreen animated:YES];
        } else {
            [self switchToScreen:_mainMenuScreen animated:YES];
        }
    }
}

#pragma mark JCSFlipUIMultiplayerScreenDelegate methods

- (void)matchMakingCancelledFromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_mainMenuScreen animated:YES];
    }
}

- (void)matchMakingFailedWithError:(NSError *)error fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_mainMenuScreen animated:YES];
        
        // display the error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB gameState:(JCSFlipGameState *)gameState match:(GKTurnBasedMatch *)match animateLastMove:(BOOL)animateLastMove moveInputDisabled:(BOOL)moveInputDisabled fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen {
    if (screen.screenEnabled) {
        [_gameScreen prepareGameWithState:gameState playerA:playerA playerB:playerB match:match animateLastMove:animateLastMove moveInputDisabled:moveInputDisabled];
    }
}

- (void)startPreparedGameFromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_gameScreen animated:YES completion:^{
            [_gameScreen startGame];
        }];
    }
}

#pragma mark JCSFlipGameCenterInviteDelegate methods

- (void)presentInviteWithPlayers:(NSArray *)playersToInvite {
    _multiplayerScreen.playersToInvite = playersToInvite;
    [self switchToScreen:_multiplayerScreen animated:YES];
}

@end
