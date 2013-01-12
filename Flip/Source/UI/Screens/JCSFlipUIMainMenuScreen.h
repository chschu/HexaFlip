//
//  JCSFlipUIMainMenuScreen.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScreen.h"

#import "cocos2d.h"

@protocol JCSFlipUIMainMenuScreenDelegate;

@interface JCSFlipUIMainMenuScreen : CCNode <JCSFlipUIScreen>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIMainMenuScreenDelegate> delegate;

@end
