//
//  JCSFlipUIMainMenuScreen.m
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "JCSFlipUIMainMenuScreen.h"
#import "JCSButton.h"
#import "JCSFlipUIMainMenuScreenDelegate.h"

@implementation JCSFlipUIMainMenuScreen {
    JCSButton *_playMultiItem;
}

@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

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
        
        // register for the game center authentication
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(playerAuthenticationDidChangeNotification:)
                   name:GKPlayerAuthenticationDidChangeNotificationName
                 object:nil];
        
        // synchronize the UI state
        [self syncUIState];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)syncUIState {
    _playMultiItem.isEnabled = [GKLocalPlayer localPlayer].isAuthenticated;
}
    
- (void)playerAuthenticationDidChangeNotification:(NSNotification *)notification {
    [self syncUIState];
}

@end
