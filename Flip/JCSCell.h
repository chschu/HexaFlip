//
//  JCSCell.h
//  Flip
//
//  Created by Christian Schuster on 16.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSPlayer.h"

@interface JCSCell : NSObject

@property (nonatomic) JCSPlayer *owner;

- (void)occupyWithPlayer:(JCSPlayer *) player;
- (void)flip;

@end
