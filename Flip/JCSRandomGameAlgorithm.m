//
//  JCSRandomGameAlgorithm.m
//  Flip
//
//  Created by Christian Schuster on 24.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSRandomGameAlgorithm.h"

@implementation JCSRandomGameAlgorithm {
    NSUInteger _seed;
}

- (id)initWithSeed:(NSUInteger)seed {
    if (self = [super init]) {
        _seed = seed;
    }
    return self;
}

- (id)moveAtNode:(id<JCSGameNode>)node {
    NSArray *moves = [self movesOfNode:node];
    
    NSUInteger count = [moves count];
    if (count == 0) {
        return nil;
    }
    
    NSUInteger index = (NSUInteger) (count * rand_r(&_seed) / RAND_MAX);
    return [moves objectAtIndex:index];
}

- (NSArray *)movesOfNode:(id<JCSGameNode>)node {
    NSMutableArray *result = [NSMutableArray array];
    
    [node enumerateChildrenUsingBlock:^(id move, id<JCSGameNode> child, BOOL *stop) {
        [result addObject:move];
    }];
    
    return [result copy];
}

@end
