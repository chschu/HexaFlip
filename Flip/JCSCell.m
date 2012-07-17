//
//  JCSCell.m
//  Flip
//
//  Created by Christian Schuster on 16.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSCell.h"
#import "JCSPlayer.h"

@implementation JCSCell

@synthesize owner = _owner;

- (void)occupyWithPlayer:(JCSPlayer *)player {
    NSAssert(self.owner == nil, @"owner must be nil");
    NSAssert(player != nil, @"player must not be nil");
    _owner = player;
}

- (void)flip {
    
}

@end
