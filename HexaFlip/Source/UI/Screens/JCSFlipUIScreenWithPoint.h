//
//  JCSFlipUIScreenWithPoint
//  HexaFlip
//
//  Created by Christian Schuster on 16.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

// protocol for screens that also have a position, i.e. are visible somewhere
@protocol JCSFlipUIScreenWithPoint <NSObject>

// "enabled" indicator of the screen
@property (readonly, nonatomic) BOOL screenEnabled;

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

// leave the screen when the Game Center player logged out or changed?
@property (readonly, nonatomic) BOOL leaveScreenWhenPlayerLoggedOut;

// enable/disable the screen and invoke the completion handler asynchronously when everything is done
- (void)setScreenEnabled:(BOOL)screenEnabled completion:(void(^)())completion;

@end
