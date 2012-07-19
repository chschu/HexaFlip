//
//  JCSFlipMove.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexCoordinate.h"
#import "JCSHexDirection.h"

@interface JCSFlipMove : NSObject

@property (strong, readonly) JCSHexCoordinate *start; 
@property (readonly) JCSHexDirection direction; 

// recycle cached instances
+ (id)moveWithStart:(JCSHexCoordinate *)start direction:(JCSHexDirection)direction;

// initialize new instances
- (id)initWithStart:(JCSHexCoordinate *)start direction:(JCSHexDirection)direction;

@end
