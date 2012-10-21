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

@end
