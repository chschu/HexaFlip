//
//  JCSFlipPlayerAI.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameState+GameNode.h"
#import "JCSGameAlgorithm.h"
#import "JCSFlipMove.h"
#import "JCSFlipPlayerMoveInputDelegate.h"

#import "cocos2d.h"

@implementation JCSFlipPlayerAI

@synthesize name = _name;
@synthesize algorithm = _algorithm;
@synthesize moveInputDelegate = _moveInputDelegate;

+ (id)playerWithName:(NSString *)name algorithm:(id<JCSGameAlgorithm>)algorithm {
    return [[self alloc] initWithName:name algorithm:algorithm];
}

- (id)initWithName:(NSString *)name algorithm:(id<JCSGameAlgorithm>)algorithm {
    if (self = [super init]) {
        _name = name;
        _algorithm = algorithm;
        _moveInputDelegate = nil;
    }
    return self;
}

- (BOOL)localControls {
    return NO;
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // determine move asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        JCSFlipMove *move = [_algorithm moveAtNode:state];
        // notify in main thread
        double delay = 0;
        if (!move.skip) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [_moveInputDelegate inputSelectedStartRow:move.startRow startColumn:move.startColumn];
            });
            delay += 0.25;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [_moveInputDelegate inputSelectedDirection:move.direction startRow:move.startRow startColumn:move.startColumn];
            });
            delay += 0.25;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [_moveInputDelegate inputClearedDirection:move.direction startRow:move.startRow startColumn:move.startColumn];
                [_moveInputDelegate inputClearedStartRow:move.startRow startColumn:move.startColumn];
            });
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            // tell the delegate to make that move
            [_moveInputDelegate inputConfirmedWithMove:move];
        });
    });
}

@end
