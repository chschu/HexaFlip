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
    
    BOOL _multiplayer;
    
    // currently active screen
    // this is the only screen with screenEnabled == YES
    id<JCSFlipUIScreen> _activeScreen;
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
    
    [self addChild:_parallax];
    
    // enable the main menu screen
    [self switchToScreen:_mainMenuScreen animated:NO];
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
- (void)switchToScreen:(id<JCSFlipUIScreen>)screen animated:(BOOL)animated completionBlock:(void(^)())block {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    // action to disable the old screen
    id<JCSFlipUIScreen> oldScreen = _activeScreen;
    CCCallBlock *disableOldScreen = [CCCallBlock actionWithBlock:^{
        oldScreen.screenEnabled = NO;
        _activeScreen = nil;
    }];
    [actions addObject:disableOldScreen];

    if ([screen conformsToProtocol:@protocol(JCSFlipUIScreenWithPoint)]) {
        id<JCSFlipUIScreenWithPoint> screenWithPoint = (id<JCSFlipUIScreenWithPoint>) screen;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGPoint winSizePoint = ccpFromSize(winSize);
        
        CGPoint targetPosition = ccpCompMult(screenWithPoint.screenPoint,ccpMult(winSizePoint,-1));

        CCAction *moveToNewScreen;
        if (animated) {
            moveToNewScreen = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:targetPosition]];
        } else {
            moveToNewScreen = [CCCallBlockN actionWithBlock:^(CCNode *node) {
                node.position = targetPosition;
            }];
        }
        [actions addObject:moveToNewScreen];
    }

    // action to enable the new screen
    CCCallBlock *enableNewScreen = [CCCallBlock actionWithBlock:^{
        screen.screenEnabled = YES;
        _activeScreen = screen;
    }];
    [actions addObject:enableNewScreen];

    if (block != nil) {
        // action to call the given block
        [actions addObject:[CCCallBlock actionWithBlock:block]];
    }

    // start the collected actions
    [_parallax runAction:[CCSequence actionWithArray:actions]];
}

// convenience method to switch the screen without a completion block
- (void)switchToScreen:(id<JCSFlipUIScreen>)screen animated:(BOOL)animated {
    [self switchToScreen:screen animated:animated completionBlock:nil];
}

#pragma mark JCSFlipUIMainMenuScreenDelegate methods

- (void)playSingleFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen {
    if (screen.screenEnabled) {
        _multiplayer = NO;
        [self switchToScreen:_playerMenuScreen animated:YES];
    }
}

- (void)playMultiFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen {
    if (screen.screenEnabled) {
        _multiplayer = YES;
        [self switchToScreen:_multiplayerScreen animated:YES];
    }
}

#pragma mark JCSFlipUIPlayerMenuScreenDelegate methods

- (void)startGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB fromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    if (screen.screenEnabled) {
        [_gameScreen prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:playerA playerB:playerB match:nil];
        [self switchToScreen:_gameScreen animated:YES completionBlock:^{
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

- (void)exitFromGameScreen:(JCSFlipUIGameScreen *)screen {
    if (screen.screenEnabled) {
        if (_multiplayer) {
            [self switchToScreen:_multiplayerScreen animated:YES];
        } else {
            // TODO confirmation screen
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

- (void)switchToGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB gameState:(JCSFlipGameState *)gameState match:(GKTurnBasedMatch *)match fromMultiplayerScreen:(JCSFlipUIMultiplayerScreen *)screen {
    if (screen.screenEnabled) {
        [_gameScreen prepareGameWithState:gameState playerA:playerA playerB:playerB match:match];
        [self switchToScreen:_gameScreen animated:YES completionBlock:^{
            [_gameScreen startGame];
        }];
    }
}

@end
