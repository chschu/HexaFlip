//
//  JCSFlipPlayerLocal.m
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerLocal.h"

@implementation JCSFlipPlayerLocal

@synthesize name = _name;
@synthesize moveInputDelegate = _moveInputDelegate;

+ (id)playerWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

- (BOOL)localControls {
    return YES;
}

- (void)opponentDidMakeMove:(JCSFlipGameState *)state {
    // do nothing, the player will see it
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, the player will make a move
    // TODO visual notification
}

@end
