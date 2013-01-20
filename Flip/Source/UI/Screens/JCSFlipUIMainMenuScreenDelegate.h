//
//  JCSFlipUIMainMenuScreenDelegate.h
//  HexaFlip
//
//  Created by Christian Schuster on 03.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@class JCSFlipUIMainMenuScreen;

// protocol for actions triggered by the main menu screen
@protocol JCSFlipUIMainMenuScreenDelegate <NSObject>

// "Single Player" button has been tapped
- (void)playSingleFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen;

// "Multi Player" button has been tapped
- (void)playMultiFromMainMenuScreen:(JCSFlipUIMainMenuScreen *)screen;

@end
