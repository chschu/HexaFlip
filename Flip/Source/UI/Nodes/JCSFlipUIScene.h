//
//  JCSFlipUIScene.h
//  Flip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

#import "JCSFlipUIMainMenuScreenDelegate.h"
#import "JCSFlipUIPlayerMenuScreenDelegate.h"
#import "JCSFlipUIGameScreenDelegate.h"
#import "JCSFlipUIOutcomeScreenDelegate.h"

@interface JCSFlipUIScene : CCScene <JCSFlipUIMainMenuScreenDelegate, JCSFlipUIPlayerMenuScreenDelegate, JCSFlipUIGameScreenDelegate, JCSFlipUIOutcomeScreenDelegate>

@end
