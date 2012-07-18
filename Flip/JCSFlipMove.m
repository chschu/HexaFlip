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

@synthesize start = _start;
@synthesize direction = _direction;


#pragma mark class methods

+ (void)initialize {
    [super initialize];
    _cache = [[NSCache alloc] init];
}

+ (id)moveWithStart:(JCSHexCoordinate *)start direction:(JCSHexDirection)direction {
    NSString *key = [NSString stringWithFormat:@"%d:%d-%d", start.row, start.column, direction];
    JCSFlipMove *cached = [_cache objectForKey:key];
    if (cached == nil) {
        cached = [[self alloc] initWithStart:start direction:direction];
        [_cache setObject:cached forKey:key];
    }
    return cached;
}

#pragma mark instance methods

- (id)initWithStart:(JCSHexCoordinate *)start direction:(JCSHexDirection)direction {
    if (self = [super init]) {
        _start = start;
        _direction = direction;
    }
    return self;
}

#pragma mark NSCopying methods

- (id)copyWithZone:(NSZone *)zone {
    // because instances of this class are immutable, we may use the same instance as copy
    return self;
}

@end
