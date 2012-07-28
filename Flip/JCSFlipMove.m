//
//  JCSFlipMove.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSFlipMutableMove.h"

@implementation JCSFlipMove

#pragma mark properties

@synthesize skip = _skip;
@synthesize startRow = _startRow;
@synthesize startColumn = _startColumn;
@synthesize direction = _direction;

#pragma mark class methods

+ (id)moveWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    return [[self alloc] initWithStartRow:startRow startColumn:startColumn direction:direction];
}

+ (id)moveSkip {
    return [[self alloc] initSkip];
}

#pragma mark instance methods

// private designated initializer
- (id)initWithSkip:(BOOL)skip startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    if (self = [super init]) {
        _skip = skip;
        _startRow = startRow;
        _startColumn = startColumn;
        _direction = direction;
    }
    return self;
}

- (id)initWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    return [self initWithSkip:NO startRow:startRow startColumn:startColumn direction:direction];
}

- (id)initSkip {
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

- (id)copyWithZone:(NSZone *)zone {
    return [[JCSFlipMove allocWithZone:zone] initWithSkip:_skip startRow:_startRow startColumn:_startColumn direction:_direction];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[JCSFlipMutableMove allocWithZone:zone] initWithSkip:_skip startRow:_startRow startColumn:_startColumn direction:_direction];
}

@end
