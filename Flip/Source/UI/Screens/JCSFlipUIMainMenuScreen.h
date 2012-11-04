//
//  JCSFlipUIMainMenuScreen.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

#import "JCSFlipUIMainMenuScreenDelegate.h"
#import "JCSFlipUIScreen.h"

@interface JCSFlipUIMainMenuScreen : CCNode <JCSFlipUIScreen>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIMainMenuScreenDelegate> delegate;

@end
