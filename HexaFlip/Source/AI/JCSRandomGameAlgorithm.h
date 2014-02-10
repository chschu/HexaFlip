//
//  JCSRandomGameAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"

@interface JCSRandomGameAlgorithm : NSObject <JCSGameAlgorithm>

- (instancetype)initWithSeed:(NSUInteger)seed;

@end
