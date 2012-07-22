//
//  JCSFlipMove.h
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexDirection.h"

@interface JCSFlipMove : NSObject

@property (readonly) NSInteger startRow;
@property (readonly) NSInteger startColumn;
@property (readonly) JCSHexDirection direction; 

// recycle cached instances
+ (id)moveWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;

// initialize new instances
- (id)initWithStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn direction:(JCSHexDirection)direction;

@end
