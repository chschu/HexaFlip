//
//  JCSRandomGameAlgorithm.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithm.h"
#import "JCSGameAlgorithmBase.h"

@interface JCSRandomGameAlgorithm : JCSGameAlgorithmBase <JCSGameAlgorithm>

- (instancetype)initWithSeed:(unsigned int)seed;

@end
