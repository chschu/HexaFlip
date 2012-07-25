//
//  JCSFlipMove.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"

@implementation JCSFlipMove

#pragma static variables

// instance cache
NSCache *_cache;

#pragma mark properties

@synthesize skip = _skip;
@synthesize startRow = _startRow;
@synthesize startColumn = _startColumn;
@synthesize direction = _direction;

#pragma mark class methods

+ (void)initialize {
    [super initialize];
    _cache = [[NSCache alloc] init];
}

+ (id)moveWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction {
    NSString *key = [NSString stringWithFormat:@"%d:%d-%d", startRow, startColumn, direction];
    JCSFlipMove *cached = [_cache objectForKey:key];
    if (cached == nil) {
        cached = [[self alloc] initWithStartRow:startRow startColumn:startColumn direction:direction];
        [_cache setObject:cached forKey:key];
    }
    return cached;
}

+ (id)moveSkip {
    NSString *key = @"skip";
    JCSFlipMove *cached = [_cache objectForKey:key];
    if (cached == nil) {
        cached = [[self alloc] initSkip];
        [_cache setObject:cached forKey:key];
    }
    return cached;
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

@end
