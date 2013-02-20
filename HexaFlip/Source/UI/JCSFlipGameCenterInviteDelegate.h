//
//  JCSFlipGameCenterInviteDelegate.h
//  HexaFlip
//
//  Created by Christian Schuster on 30.01.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

@protocol JCSFlipGameCenterInviteDelegate <NSObject>

- (void)presentInviteWithPlayers:(NSArray *)playersToInvite;

@end
