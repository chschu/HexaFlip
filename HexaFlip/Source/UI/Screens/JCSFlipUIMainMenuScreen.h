//
//  JCSFlipUIMainMenuScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBaseScreen.h"

#import "cocos2d.h"

@protocol JCSFlipUIMainMenuScreenDelegate;

@interface JCSFlipUIMainMenuScreen : JCSFlipUIBaseScreen

// the screen delegate
@property (weak, nonatomic) id<JCSFlipUIMainMenuScreenDelegate> delegate;

@end
