//
//  JCSHexCoordinate.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#include "JCSHexDirection.h"

// coordinate pair (row,column) on a hexagonal grid
// (0,1) is E of (0,0), and (1,0) is NE of (0,0)
@interface JCSHexCoordinate : NSObject <NSCopying>

@property (readonly) NSInteger row; 
@property (readonly) NSInteger column; 

// recycle cached instances
+ (id)hexCoordinateForOrigin;
+ (id)hexCoordinateWithRow:(NSInteger)row column:(NSInteger)column;
+ (id)hexCoordinateWithHexCoordinate:(JCSHexCoordinate *)coordinate direction:(JCSHexDirection)direction;

// initialize new instances
- (id)initWithRow:(NSInteger)row column:(NSInteger)column;
- (id)initWithHexCoordinate:(JCSHexCoordinate *)coordinate direction:(JCSHexDirection)direction;

// hexagonal distance between the receiver and another coordinate
- (NSInteger) distanceTo:(JCSHexCoordinate *)other;

@end
