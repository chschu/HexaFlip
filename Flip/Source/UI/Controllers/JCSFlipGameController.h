//
//  JCSFlipGameController.h
//  Flip
//
//  Created by Christian Schuster on 30.08.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "JCSFlipPlayer.h"

@interface JCSFlipGameController : UIViewController <CCDirectorDelegate>

@property (nonatomic) id<JCSFlipPlayer> playerA;
@property (nonatomic) id<JCSFlipPlayer> playerB;

// block invoked when the game should be exited
@property (copy, nonatomic) void(^exitBlock)(id sender);

@end
