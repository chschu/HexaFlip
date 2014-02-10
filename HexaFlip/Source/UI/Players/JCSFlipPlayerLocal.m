//
//  JCSFlipPlayerLocal.m
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerLocal.h"

#import "cocos2d.h"

@implementation JCSFlipPlayerLocal

+ (instancetype)player {
    return [[self alloc] init];
}

- (BOOL)localControls {
    return YES;
}

- (NSString *)activityIndicatorSpriteFrameNameFormat {
    return @"indicator-local-frame-%d.png";
}

- (NSUInteger)activityIndicatorSpriteFrameCount {
    return 1;
}

- (CGPoint)activityIndicatorAnchorPoint {
    return ccp(0.5,0.5);
}

- (CGPoint)activityIndicatorPosition {
    return ccp(-180,60);
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

- (NSString *)description {
    return @"(Local Player)";
}

@end
