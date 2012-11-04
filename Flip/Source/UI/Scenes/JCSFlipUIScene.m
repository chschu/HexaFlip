//
//  JCSFlipUIScene.m
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScene.h"
#import "JCSFlipUIBackgroundLayer.h"
#import "JCSFlipUIGameScreen.h"
#import "JCSFlipUIMainMenuScreen.h"
#import "JCSFlipUIPlayerMenuScreen.h"

@implementation JCSFlipUIScene {
    // global parallax node
    CCParallaxNode *_parallax;

    // main menu screen
    JCSFlipUIMainMenuScreen *_mainMenuScreen;

    // player selectio menu screen
    JCSFlipUIPlayerMenuScreen *_playerMenuScreen;

    // game screen
    JCSFlipUIGameScreen *_gameScreen;
    
    // currently active screen
    // this is the only screen with screenEnabled == YES
    id<JCSFlipUIScreen> _activeScreen;
}

// this could be done in -init, but then the scene is rendered in portrait mode, which breaks the layout
- (void)onEnter {
    [super onEnter];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint winSizePoint = ccpFromSize(winSize);
    
    _parallax = [CCParallaxNode node];

    // still background
    CCNode *backgroundLayer = [JCSFlipUIBackgroundLayer node];
    // TODO use tile map and scroll background?
    backgroundLayer.scale = 2;
    [_parallax addChild:backgroundLayer z:0 parallaxRatio:ccp(-0.1,-0.1) positionOffset:ccp(0,0)];

    // main menu screen
    _mainMenuScreen = [JCSFlipUIMainMenuScreen node];
    _mainMenuScreen.delegate = self;
    _mainMenuScreen.screenPoint = ccp(0,0);
    [_parallax addChild:_mainMenuScreen z:1 parallaxRatio:ccp(1,1) positionOffset:ccpCompMult(_gameScreen.screenPoint,winSizePoint)];
    
    // player selection menu screen
    _playerMenuScreen = [JCSFlipUIPlayerMenuScreen node];
    _playerMenuScreen.delegate = self;
    _playerMenuScreen.screenPoint = ccp(1,1);
    [_parallax addChild:_playerMenuScreen z:1 parallaxRatio:ccp(1,1) positionOffset:ccpCompMult(_playerMenuScreen.screenPoint,winSizePoint)];
    
    // game screen
    _gameScreen = [JCSFlipUIGameScreen node];
    _gameScreen.delegate = self;
    _gameScreen.screenPoint = ccp(1,-1);
    [_parallax addChild:_gameScreen z:1 parallaxRatio:ccp(1,1) positionOffset:ccpCompMult(_gameScreen.screenPoint,winSizePoint)];

    [self addChild:_parallax];

    // enable the main menu screen
    _mainMenuScreen.screenEnabled = YES;
    _activeScreen = _mainMenuScreen;
}

- (void)scrollToScreen:(id<JCSFlipUIScreen>)screen {
    // disable the old screen
    _activeScreen.screenEnabled = NO;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint winSizePoint = ccpFromSize(winSize);

    id action = [CCMoveTo actionWithDuration:1 position:ccpCompMult(screen.screenPoint,ccpMult(winSizePoint,-1))];
    id easedAction = [CCEaseElasticOut actionWithAction:action period:0.8];
    [_parallax runAction:easedAction];
    
    // enable the new screen
    _activeScreen = screen;
    _activeScreen.screenEnabled = YES;
}

#pragma mark JCSFlipUIMainMenuScreenDelegate methods

- (void)play {
    [self scrollToScreen:_playerMenuScreen];
}

#pragma mark JCSFlipUIPlayerMenuScreenDelegate methods

- (void)startGameWithPlayerA:(id<JCSFlipPlayer>)playerA playerB:(id<JCSFlipPlayer>)playerB {
    // prepare game screen
    [_gameScreen startGameWithState:[[JCSFlipGameState alloc] initDefaultWithSize:5] playerA:playerA playerB:playerB];
    
    [self scrollToScreen:_gameScreen];
}

#pragma mark JCSFLipUIGameScreenDelegate methods

- (void)gameEndedWithStatus:(JCSFlipGameStatus)status {
    // TODO scoll to outcome specific screen
    
    [self scrollToScreen:_mainMenuScreen];
}

@end
