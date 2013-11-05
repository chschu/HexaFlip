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

@synthesize delegate = _delegate;

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
        
#ifdef DEBUG
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        
        NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [infoDict objectForKey:@"CFBundleVersion"];
        NSString *revision = [infoDict objectForKey:@"JCSRevision"];
        NSString *infoString = [NSString stringWithFormat:@"%@ (%@) :: %@", version, revision, build];
        CCLabelTTF *infoLabel = [CCLabelTTF labelWithString:infoString fontName:@"Verdana" fontSize:8];
        infoLabel.anchorPoint = ccp(0,0);
        infoLabel.position = ccp(10,10);
        [self addChild:infoLabel];
#endif
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
