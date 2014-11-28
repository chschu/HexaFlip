//
//  JCSNegaScoutGameAlgorithm.m
//  HexaFlip
//
//  Created by Christian Schuster on 22.10.13.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSNegaScoutGameAlgorithm.h"
#import "JCSGameHeuristic.h"
#import "JCSGameNode.h"

@implementation JCSNegaScoutGameAlgorithm {
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

- (id)moveAtNode:(id<JCSGameNode>)node {
    _node = node;
    _count = 0;
    NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:_depth];
    NSDate *start = [NSDate date];
    
    float score = [self negaScoutWithDepth:_depth alpha:-INFINITY beta:INFINITY principalVariation:pv];
    
    NSLog(@"analyzed %lu nodes in %.3f seconds, got principal variation [%@] with score %.3f%@",
          (unsigned long)_count, [[NSDate date] timeIntervalSinceDate:start], [pv componentsJoinedByString:@", "], score, self.canceled ? @" (canceled)" : @"");
    
    return [pv count] > 0 ? pv[0] : nil;
}

- (float)negaScoutWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta principalVariation:(NSMutableArray *)principalVariation {
    _count++;
    
    if (depth == 0 || _node.leaf) {
        // maximum depth reached, or leaf node - take the node's heuristic value
        return [_heuristic valueOfNode:_node];
    }
    
    float __block localAlpha = alpha;
    NSMutableArray *pv = [NSMutableArray arrayWithCapacity:depth-1];
    float __block bestScore;
    BOOL __block first = YES;
    
    @autoreleasepool {
        [self applyPossibleMovesToNode:_node sortByValue:^float(id move) {
            return [_heuristic valueOfNode:_node];
        } invokeBlock:^BOOL(id move) {
            float score;
            // skip minimal-window search for first move
            if (!first) {
                // search with minimal window
                score = -[self negaScoutWithDepth:depth-1 alpha:-localAlpha-1 beta:-localAlpha principalVariation:pv];
                if (score > bestScore) {
                    // improved
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:move atIndex:0];
                    bestScore = score;
                }
                if (score >= beta) {
                    // no further improvement necessary
                    return NO;
                }
            }
            if (first || score > localAlpha) {
                // perform full-window search (the only search for first move)
                score = -[self negaScoutWithDepth:depth-1 alpha:-beta beta:-localAlpha principalVariation:pv];
                if (first || score > bestScore) {
                    // improved (or first move)
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:move atIndex:0];
                    bestScore = score;
                    first = NO;
                }
                if (score >= beta) {
                    // no further improvement necessary
                    return NO;
                }
                if (score > localAlpha) {
                    // new lower bound
                    localAlpha = score;
                }
            }
            return YES;
        }];
        return bestScore;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(NegaScout Algorithm; %@; Depth %lu)", _heuristic, (unsigned long)_depth];
}

@end
