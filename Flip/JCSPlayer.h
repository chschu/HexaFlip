//
//  JCSPlayer.h
//  Flip
//
//  Created by Christian Schuster on 16.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCSPlayer : NSObject

+ (JCSPlayer *) A;
+ (JCSPlayer *) B;

@property (readonly) JCSPlayer *other;

@end
