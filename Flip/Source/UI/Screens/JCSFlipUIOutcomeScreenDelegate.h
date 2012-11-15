//
//  JCSFlipUIOutcomeScreenDelegate.h
//  Flip
//
//  Created by Christian Schuster on 13.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@class JCSFlipUIOutcomeScreen;

@protocol JCSFlipUIOutcomeScreenDelegate <NSObject>

// "Rewind" button has been tapped
- (void)rewindFromOutcomeScreen:(JCSFlipUIOutcomeScreen *)screen;

@end
