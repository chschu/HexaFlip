//
//  JCSFlipMove.m
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSFlipMoveInputDelegate.h"

@implementation JCSFlipMove

#pragma mark properties

@synthesize value = _value;

#pragma mark class methods

+ (instancetype)moveWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    return [[self alloc] initWithStartRow:startRow startColumn:startColumn direction:direction];
}

+ (instancetype)moveSkip {
    return [[self alloc] initSkip];
}

#pragma mark instance methods

// private designated initializer
- (instancetype)initWithSkip:(BOOL)skip startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    if (self = [super init]) {
        _skip = skip;
        _startRow = startRow;
        _startColumn = startColumn;
        _direction = direction;
    }
    return self;
}

- (instancetype)initWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    return [self initWithSkip:NO startRow:startRow startColumn:startColumn direction:direction];
}

- (instancetype)initSkip {
    return [self initWithSkip:YES startRow:0 startColumn:0 direction:JCSHexDirectionMin];
}

- (NSInteger)startRow {
    NSAssert(!_skip, @"may not be invoked for skip move");
    return _startRow;
}

- (NSInteger)startColumn {
    NSAssert(!_skip, @"may not be invoked for skip move");
    return _startColumn;
}

- (JCSHexDirection)direction {
    NSAssert(!_skip, @"may not be invoked for skip move");
    return _direction;
}

- (void)dispatchToMainQueueAfterDelay:(double)seconds block:(dispatch_block_t)block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

- (void)performInputWithMoveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate {
    double delay = 0;
    if (!_skip) {
        [self dispatchToMainQueueAfterDelay:delay block:^{
            [moveInputDelegate inputSelectedStartRow:_startRow startColumn:_startColumn];
        }];
        delay += 0.25;
        [self dispatchToMainQueueAfterDelay:delay block:^{
            [moveInputDelegate inputSelectedDirection:_direction startRow:_startRow startColumn:_startColumn];
        }];
        delay += 0.25;
        [self dispatchToMainQueueAfterDelay:delay block:^{
            [moveInputDelegate inputClearedDirection:_direction startRow:_startRow startColumn:_startColumn];
            [moveInputDelegate inputClearedStartRow:_startRow startColumn:_startColumn];
            [moveInputDelegate inputConfirmedWithMove:self];
        }];
    } else {
        [self dispatchToMainQueueAfterDelay:delay block:^{
            [moveInputDelegate inputConfirmedWithMove:self];
        }];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return [[JCSFlipMove allocWithZone:zone] initWithSkip:_skip startRow:_startRow startColumn:_startColumn direction:_direction];
}

- (NSComparisonResult)compareByValueTo:(id<JCSMove>)other {
    float v1 = _value;
    float v2 = other.value;
    if (v1 < v2) {
        return NSOrderedAscending;
    }
    if (v1 > v2) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (NSString *)description {
    if (_skip) {
        return @"skip";
    }
    return [NSString stringWithFormat:@"(%d,%d)-%@", _startRow, _startColumn, JCSHexDirectionName(_direction)];
}

@end
