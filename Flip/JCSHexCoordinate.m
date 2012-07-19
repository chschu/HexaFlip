//
//  JCSHexCoordinate.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexCoordinate.h"

#define JCS_ROW_DELTA(direction) ((direction) == JCSHexDirectionNE || (direction) == JCSHexDirectionNW) - ((direction) == JCSHexDirectionSW || (direction) == JCSHexDirectionSE)
#define JCS_COL_DELTA(direction) ((direction) == JCSHexDirectionE || (direction) == JCSHexDirectionSE) - ((direction) == JCSHexDirectionNW || (direction) == JCSHexDirectionW)

@implementation JCSHexCoordinate

#pragma static variables

// instance cache
NSCache *_cache;

#pragma mark properties

@synthesize row = _row;
@synthesize column = _column;

#pragma mark class methods

+ (void)initialize {
    [super initialize];
    _cache = [[NSCache alloc] init];
}

+ (id)hexCoordinateForOrigin {
    return [self hexCoordinateWithRow:0 column:0];
}

+ (id)hexCoordinateWithRow:(NSInteger)row column:(NSInteger)column {
    NSString *key = [NSString stringWithFormat:@"%d:%d", row, column];
    JCSHexCoordinate *cached = [_cache objectForKey:key];
    if (cached == nil) {
        cached = [[self alloc] initWithRow:row column:column];
        [_cache setObject:cached forKey:key];
    }
    return cached;
}

+ (id)hexCoordinateWithHexCoordinate:(JCSHexCoordinate *)coordinate direction:(JCSHexDirection)direction {
    return [self hexCoordinateWithRow:coordinate.row + JCS_ROW_DELTA(direction) column:coordinate.column + JCS_COL_DELTA(direction)];
}

#pragma mark instance methods

- (id)initWithRow:(NSInteger)row column:(NSInteger)column {
    if (self = [super init]) {
        _row = row;
        _column = column;
    }
    return self;
}

- (id)initWithHexCoordinate:(JCSHexCoordinate *)coordinate direction:(JCSHexDirection)direction {
    return [self initWithRow:coordinate.row + JCS_ROW_DELTA(direction) column:coordinate.column + JCS_COL_DELTA(direction)];
}

- (NSInteger)distanceTo:(JCSHexCoordinate *)other {
    NSInteger dr = abs(_row - other.row);
    NSInteger dc = abs(_column - other.column);
    NSInteger dz = abs((-_row-_column) - (-other.row-other.column));
    return MAX(MAX(dr, dc), dz);
}

#pragma mark NSCopying methods

- (id)copyWithZone:(NSZone *)zone {
    // because instances of this class are immutable, we may use the same instance as copy
    return self;
}

#pragma mark Collection support

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object class] != [self class]) {
        return NO;
    }
    JCSHexCoordinate *other = (JCSHexCoordinate *)object;
    return other.row == _row && other.column == _column; 
}

- (NSUInteger)hash {
    return 31 * _row + _column;
}

@end
