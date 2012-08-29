//
//  JCSRandomGameAlgorithm.h
//  Flip
//
//  Created by Christian Schuster on 24.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSGameNode.h"

@interface JCSRandomGameAlgorithm : NSObject <JCSGameAlgorithm>

- (id)initWithSeed:(NSUInteger)seed;

@end
