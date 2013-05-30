//
//  JCSFlipPlayerAI.m
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameState.h"
#import "JCSGameAlgorithm.h"
#import "JCSFlipMove.h"
#import "JCSFlipMoveInputDelegate.h"

#import "cocos2d.h"

@implementation JCSFlipPlayerAI

@synthesize algorithm = _algorithm;
@synthesize moveInputDelegate = _moveInputDelegate;

+ (id)playerWithAlgorithm:(id<JCSGameAlgorithm>)algorithm {
    return [[self alloc] initWithAlgorithm:algorithm];
}

- (id)initWithAlgorithm:(id<JCSGameAlgorithm>)algorithm {
    if (self = [super init]) {
        _algorithm = algorithm;
        _moveInputDelegate = nil;
    }
    return self;
}

- (BOOL)localControls {
    return NO;
}

- (void)opponentDidMakeMove:(JCSFlipGameState *)state {
    // do nothing, AI is not interested in that
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // determine move asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        JCSFlipMove *move = [_algorithm moveAtNode:state];
        [move performInputWithMoveInputDelegate:_moveInputDelegate];

    });
}

- (void)cancel {
    [_algorithm cancel];
}

@end
