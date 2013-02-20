//
//  JCSFlipUIScene.h
//  HexaFlip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

#import "JCSFlipUIMainMenuScreenDelegate.h"
#import "JCSFlipUIPlayerMenuScreenDelegate.h"
#import "JCSFlipUIGameScreenDelegate.h"
#import "JCSFlipUIMultiplayerScreenDelegate.h"
#import "JCSFlipGameCenterInviteDelegate.h"

@interface JCSFlipUIScene : CCScene <JCSFlipUIMainMenuScreenDelegate, JCSFlipUIPlayerMenuScreenDelegate, JCSFlipUIGameScreenDelegate, JCSFlipUIMultiplayerScreenDelegate, JCSFlipGameCenterInviteDelegate>

@end
