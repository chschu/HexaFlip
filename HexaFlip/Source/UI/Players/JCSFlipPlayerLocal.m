//
//  JCSFlipPlayerLocal.m
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerLocal.h"

@implementation JCSFlipPlayerLocal

@synthesize moveInputDelegate = _moveInputDelegate;

+ (id)player {
    return [[self alloc] init];
}

- (BOOL)localControls {
    return YES;
}

- (void)opponentDidMakeMove:(JCSFlipGameState *)state {
    // do nothing, the player will see it
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, the player will make a move
}

- (void)cancel {
    // do nothing, there is nothing asynchronous
}

@end
