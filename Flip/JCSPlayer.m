//
//  JCSPlayer.m
//  Flip
//
//  Created by Christian Schuster on 16.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSPlayer.h"

@implementation JCSPlayer

JCSPlayer *playerA = nil;
JCSPlayer *playerB = nil;

+ (JCSPlayer *)A {
    @synchronized(self) {
        if (playerA == nil) {
            playerA = [[self alloc] initPlayer];
        }
    }
    return playerA;
}

+ (JCSPlayer *)B {
    @synchronized(self) {
        if (playerB == nil) {
            playerB = [[self alloc] initPlayer];
        }
    }
    return playerB;
}

- (id)init {
    NSAssert(NO, @"Attempting to instantiate new instance. Use +A or +B.");
    return nil;
}

- (id)initPlayer {
    return [super init];
}

- (JCSPlayer *)other {
    if (self == playerA) {
        return [JCSPlayer B];
    } else if (self == playerB) {
        return [JCSPlayer A];
    } else {
        NSAssert(NO, @"Detected invalid instance.");
        return nil;
    }
}

@end
