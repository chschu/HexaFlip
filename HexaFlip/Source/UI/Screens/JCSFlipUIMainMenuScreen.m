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
#import "JCSFlipGameCenterManager.h"
#import "JCSFlipUIEvents.h"

@implementation JCSFlipUIMainMenuScreen {
    JCSButton *_playMultiItem;
}

- (id)init {
    if (self = [super init]) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        JCSButton *playSingleItem = [JCSButton buttonWithSize:JCSButtonSizeLarge name:@"play-single" block:^(id sender) {
            [nc postNotificationName:JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME object:self];
        }];
        playSingleItem.position = ccp(-60,0);
        
        _playMultiItem = [JCSButton buttonWithSize:JCSButtonSizeLarge name:@"play-multi" block:^(id sender) {
            [nc postNotificationName:JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME object:self];
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

- (void)willActivateScreen {
    // register for game center authentication notification
    [[JCSFlipGameCenterManager sharedInstance] addPlayerAuthenticationObserver:self selector:@selector(playerAuthenticationDidChange:)];

    // synchronize the UI state
    [self syncUIState];
}

- (void)didDeactivateScreen {
    // unregister from game center authentication notification
    [[JCSFlipGameCenterManager sharedInstance] removePlayerAuthenticationObserver:self];
}

- (BOOL)leaveScreenWhenPlayerLoggedOut {
    return NO;
}

@end
