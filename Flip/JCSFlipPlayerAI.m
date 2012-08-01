//
//  JCSFlipPlayerAI.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameState+GameNode.h"

#import "cocos2d.h"

@implementation JCSFlipPlayerAI {
    // delegate for automatic move input, in case the player is supposed to do that
    id<JCSFlipMoveInputDelegate> _moveInputDelegate;
}

@synthesize name = _name;
@synthesize algorithm = _algorithm;

- (id)initWithName:(NSString *)name algorithm:(id<JCSGameAlgorithm>)algorithm moveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    if (self = [super init]) {
        _name = name;
        _algorithm = algorithm;
        _moveInputDelegate = moveInputDelegate;
    }
    return self;
}

- (BOOL)localControls {
    return NO;
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // determine move asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JCSFlipMove *move = [_algorithm moveAtNode:state];
        // notify in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: delegate might have been destroyed - this should set the delegate to nil
            [_moveInputDelegate inputSelectedStartRow:move.startRow startColumn:move.startColumn];
            [_moveInputDelegate inputSelectedDirection:move.direction];
            [_moveInputDelegate inputConfirmedWithMove:move];
        });
    });
}

@end
