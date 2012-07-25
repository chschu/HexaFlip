//
//  JCSMinimaxAlgorithm.h
//  Flip
//
//  Created by Christian Schuster on 21.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSGameNode.h"

@interface JCSMinimaxGameAlgorithm : NSObject <JCSGameAlgorithm>

@property (readonly) NSInteger depth;

- (id)initWithDepth:(NSInteger)depth;

@end
