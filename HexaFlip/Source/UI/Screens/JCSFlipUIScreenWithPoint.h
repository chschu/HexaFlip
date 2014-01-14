//
//  JCSFlipUIScreenWithPoint
//  HexaFlip
//
//  Created by Christian Schuster on 16.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

// protocol for screens that also have a position, i.e. are visible somewhere
@protocol JCSFlipUIScreenWithPoint <NSObject>

// row and column where the screen is placed
// both coordinates must be integers
@property (nonatomic) CGPoint screenPoint;

// leave the screen when the Game Center player logged out or changed?
@property (readonly, nonatomic) BOOL leaveScreenWhenPlayerLoggedOut;

@optional

// optional method; perform actions before the screen will be activated, while it is completely invisible
- (void)willActivateScreen;

// optional method; activate the screen, while it is fully visible
- (void)didActivateScreen;

// optional method; deactivate the screen, while it is fully visible
- (void)willDeactivateScreen;

// optional method; perform actions after the screen has been deactivated, while it is completely invisible
- (void)didDeactivateScreen;

@end
