//
//  JCSFlipUIPlayerMenuScreen.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScreen.h"

#import "cocos2d.h"

@protocol JCSFlipUIPlayerMenuScreenDelegate;

@interface JCSFlipUIPlayerMenuScreen : CCNode <JCSFlipUIScreen>

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIPlayerMenuScreenDelegate> delegate;

@end
