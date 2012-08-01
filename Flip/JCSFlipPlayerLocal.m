//
//  JCSFlipPlayerLocal.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerLocal.h"

@implementation JCSFlipPlayerLocal

@synthesize name = _name;

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

- (BOOL)localControls {
    return YES;
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // do nothing, the player will make a move
}

@end
