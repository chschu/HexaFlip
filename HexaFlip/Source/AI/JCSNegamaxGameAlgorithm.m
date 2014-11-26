//
//  JCSNegamaxGameAlgorithm.m
//  HexaFlip
//
//  Created by Christian Schuster on 21.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSNegamaxGameAlgorithm.h"
#import "JCSGameHeuristic.h"
#import "JCSGameNode.h"
#import "JCSMove.h"

@implementation JCSNegamaxGameAlgorithm {
    // the heuristic evaluation to be used
    id<JCSGameHeuristic> _heuristic;
    
    // the currently analyzed node (modified during tree traversal)
    id<JCSGameNode> _node;
    
    // number of analyzed nodes (for stat output)
    NSUInteger _count;
    
    // search depth
    NSUInteger _depth;
}

- (instancetype)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic {
    NSAssert(depth > 0, @"depth must be positive");
    NSAssert(heuristic != nil, @"heuristic must not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
    }
    return self;
}

- (id<JCSMove>)moveAtNode:(id<JCSGameNode>)node {
    _node = node;
    _count = 0;
    NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:_depth];
    NSDate *start = [NSDate date];
    
    float score = [self negamaxWithDepth:_depth alpha:-INFINITY beta:INFINITY principalVariation:pv];
    
    NSLog(@"analyzed %lu nodes in %.3f seconds, got principal variation [%@] with score %.3f%@",
          (unsigned long)_count, [[NSDate date] timeIntervalSinceDate:start], [pv componentsJoinedByString:@", "], score, self.canceled ? @" (canceled)" : @"");
    
    return [pv count] > 0 ? pv[0] : nil;
}

- (float)negamaxWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta principalVariation:(NSMutableArray *)principalVariation {
    _count++;
    
    if (depth == 0 || _node.leaf) {
        // maximum depth reached, or leaf node - take the node's heuristic value
        return [_heuristic valueOfNode:_node];
    }
    
    float __block localAlpha = alpha;
    NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:depth-1];
    BOOL __block first = YES;
    
    @autoreleasepool {
        [self applyPossibleMovesToNode:_node sortByValue:^float(id<JCSMove> move) {
            return [_heuristic valueOfNode:_node];
        } invokeBlock:^BOOL(id<JCSMove> move) {
            float score = -[self negamaxWithDepth:depth-1 alpha:-beta beta:-localAlpha principalVariation:pv];
            if (score > localAlpha) {
                first = NO;
                [principalVariation setArray:pv];
                [principalVariation insertObject:move atIndex:0];
                localAlpha = score;
                if (localAlpha >= beta) {
                    return NO;
                }
            } else if (first) {
                // keep first move, just in case there are only really bad moves
                first = NO;
                [principalVariation setArray:pv];
                [principalVariation insertObject:move atIndex:0];
            }
            return YES;
        }];
    }
    
    return localAlpha;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(NegaMax Algorithm; %@; Depth %lu)", _heuristic, (unsigned long)_depth];
}

@end
