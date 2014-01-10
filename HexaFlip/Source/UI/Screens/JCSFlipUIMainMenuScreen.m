//
//  JCSFlipUIMainMenuScreen.m
//  HexaFlip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipUIMainMenuScreen.h"
#import "JCSButton.h"
#import "JCSFlipUIMainMenuScreenDelegate.h"
#import "JCSFlipGameCenterManager.h"

@implementation JCSFlipUIMainMenuScreen {
    JCSButton *_playMultiItem;
}

- (id)init {
    if (self = [super init]) {
        JCSButton *playSingleItem = [JCSButton buttonWithSize:JCSButtonSizeLarge name:@"play-single" block:^(id sender) {
            [_delegate playSingleFromMainMenuScreen:self];
        }];
        playSingleItem.position = ccp(-60,0);
        
        _playMultiItem = [JCSButton buttonWithSize:JCSButtonSizeLarge name:@"play-multi" block:^(id sender) {
            [_delegate playMultiFromMainMenuScreen:self];
        }];
        _playMultiItem.position = ccp(60,0);
        
        CCMenu *menu = [CCMenu menuWithItems:playSingleItem, _playMultiItem, nil];
        [self addChild:menu];
    }
    return self;
}

- (void)syncUIState {
    _playMultiItem.isEnabled = [JCSFlipGameCenterManager sharedInstance].isLocalPlayerAuthenticated;
}

- (void)playerAuthenticationDidChange:(NSNotification *)notification {
    [self syncUIState];
}

- (void)setScreenEnabled:(BOOL)screenEnabled completion:(void(^)())completion {
    _screenEnabled = screenEnabled;
    if (screenEnabled ) {
        // register for game center authentication notification
        [[JCSFlipGameCenterManager sharedInstance] addPlayerAuthenticationObserver:self selector:@selector(playerAuthenticationDidChange:)];
    } else {
        // unregister from game center authentication notification
        [[JCSFlipGameCenterManager sharedInstance] removePlayerAuthenticationObserver:self];
    }
    
    // synchronize the UI state
    [self syncUIState];

    if (completion != nil) {
        completion();
    }
}

- (BOOL)leaveScreenWhenPlayerLoggedOut {
    return NO;
}

@end
