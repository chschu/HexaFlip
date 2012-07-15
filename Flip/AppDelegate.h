//
//  AppDelegate.h
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) UINavigationController *navController;
@property (strong, readonly) CCDirector *director;

@end
