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
#import "JCSMove.h"

#import "cocos2d.h"

@implementation JCSFlipPlayerAI

@synthesize moveInputDelegate = _moveInputDelegate;

+ (instancetype)playerWithAlgorithm:(id<JCSGameAlgorithm>)algorithm {
    return [[self alloc] initWithAlgorithm:algorithm];
}

- (instancetype)initWithAlgorithm:(id<JCSGameAlgorithm>)algorithm {
    if (self = [super init]) {
        _algorithm = algorithm;
        _moveInputDelegate = nil;
    }
    return self;
}

- (BOOL)localControls {
    return NO;
}

- (NSString *)activityIndicatorSpriteFrameNameFormat {
    return @"indicator-ai-frame-%d.png";
}

- (NSUInteger)activityIndicatorSpriteFrameCount {
    return 3;
}

- (CGPoint)activityIndicatorAnchorPoint {
    // center of gravity of the "cloud"
    return ccp(74.0/131.0,1.0-46.0/131.0);
}

- (CGPoint)activityIndicatorPosition {
    // somewhere in the empty space on the left of the board
    return ccp(-170,74);
}

- (void)opponentDidMakeMove:(JCSFlipGameState *)state {
    // do nothing, AI is not interested in that
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // determine move asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        JCSFlipMove *move = (JCSFlipMove *)[_algorithm moveAtNode:state];
        [move performInputWithMoveInputDelegate:_moveInputDelegate];
    });
}

- (void)cancel {
    [_algorithm cancel];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(AI player; %@)", [_algorithm description]];
}

@end
