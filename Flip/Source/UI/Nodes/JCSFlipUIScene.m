//
//  JCSFlipUIScene.m
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScene.h"
#import "JCSFlipUIGameScreen.h"
#import "JCSFlipUIMainMenuScreen.h"
#import "JCSFlipUIPlayerMenuScreen.h"
#import "JCSFlipUIOutcomeScreen.h"
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
    
    // game outcome screen
    JCSFlipUIOutcomeScreen *_outcomeScreen;
    
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
    
    // outcome screen
    _outcomeScreen = [JCSFlipUIOutcomeScreen node];
    _outcomeScreen.delegate = self;
    [self addScreen:_outcomeScreen atScreenPoint:ccp(2,1) z:1];
    
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
// for screens with point (conforming to protocol JCSFlipUIScreenWithPoint), the screen is made visible, using an animation if the "animated" parameter is set to YES
// for screens without point, the "animated" parameter is ignored, because no animation is required
- (void)switchToScreen:(id<JCSFlipUIScreen>)screen animated:(BOOL)animated {
    // disable the old screen
    _activeScreen.screenEnabled = NO;
    
    if ([screen conformsToProtocol:@protocol(JCSFlipUIScreenWithPoint)]) {
        id<JCSFlipUIScreenWithPoint> screenWithPoint = (id<JCSFlipUIScreenWithPoint>) screen;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGPoint winSizePoint = ccpFromSize(winSize);
        
        CGPoint targetPosition = ccpCompMult(screenWithPoint.screenPoint,ccpMult(winSizePoint,-1));
        
        if (animated) {
            id action = [CCMoveTo actionWithDuration:1 position:targetPosition];
            id easedAction = [CCEaseExponentialOut actionWithAction:action];
            [_parallax runAction:easedAction];
        } else {
            _parallax.position = targetPosition;
        }
    }
    
    // enable the new screen
    _activeScreen = screen;
    _activeScreen.screenEnabled = YES;
}

#pragma mark JCSFlipUIMainMenuScreenDelegate methods

- (void)playSingleFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_playerMenuScreen animated:YES];
    }
}

- (void)playMultiFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen {
    if (screen.screenEnabled) {
        // TODO implement
    }
}

#pragma mark JCSFlipUIPlayerMenuScreenDelegate methods

- (void)startGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB fromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    if (screen.screenEnabled) {
        // prepare game screen
        [_gameScreen prepareGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:playerA playerB:playerB];
        
        [self switchToScreen:_gameScreen animated:YES];
        
        // start the game
        [_gameScreen startGame];
    }
}

- (void)backFromPlayerMenuScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_mainMenuScreen animated:YES];
    }
}

#pragma mark JCSFlipUIGameScreenDelegate methods

- (void)gameEndedWithStatus:(JCSFlipGameStatus)status fromGameScreen:(JCSFlipUIGameScreen *)screen {
    if (screen.screenEnabled) {
        // update and scoll to outcome screen
        _outcomeScreen.status = status;
        [self switchToScreen:_outcomeScreen animated:YES];
    }
}

- (void)gameEndedFromGameScreen:(JCSFlipUIGameScreen *)screen {
    if (screen.screenEnabled) {
        // TODO confirmation screen
        [self switchToScreen:_mainMenuScreen animated:YES];
    }
}

#pragma mark JCSFlipUIOutcomeScreenDelegate methods

- (void)rewindFromOutcomeScreen:(JCSFlipUIOutcomeScreen *)screen {
    if (screen.screenEnabled) {
        [self switchToScreen:_playerMenuScreen animated:YES];
    }
}

@end
