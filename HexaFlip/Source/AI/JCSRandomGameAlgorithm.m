//
//  JCSRandomGameAlgorithm.m
//  HexaFlip
//
//  Created by Christian Schuster on 24.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSRandomGameAlgorithm.h"
#import "JCSGameNode.h"

@implementation JCSRandomGameAlgorithm {
    unsigned int _seed;
}

- (instancetype)initWithSeed:(unsigned int)seed {
    if (self = [super init]) {
        _seed = seed;
    }
    return self;
}

- (id)moveAtNode:(id<JCSGameNode>)node {
    NSMutableArray *moves = [NSMutableArray array];
    
    [node applyAllPossibleMovesAndInvokeBlock:^(id move) {
        [moves addObject:move];
        return YES;
    }];
    
    NSUInteger count = [moves count];
    if (count == 0) {
        return nil;
    }
    
    NSUInteger index = (NSUInteger) (count * rand_r(&_seed) / RAND_MAX);
    return moves[index];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(Random Algorithm; Seed %u)", _seed];
}

@end
