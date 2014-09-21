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
#import "JCSMove.h"

@implementation JCSNegaScoutGameAlgorithm {
    // the heuristic evaluation to be used
    id<JCSGameHeuristic> _heuristic;
    
    // the currently analyzed node (modified during tree traversal)
    id<JCSGameNode> _node;
    
    // number of analyzed nodes (for stat output)
    NSUInteger _count;
    
    // search depth
    NSUInteger _depth;
    
    // the indicator for cancellation
    volatile BOOL _canceled;
}

- (instancetype)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic {
	NSAssert(depth > 0, @"depth must be positive");
	NSAssert(heuristic != nil, @"heuristic must not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
        _canceled = NO;
    }
    return self;
}

- (id<JCSMove>)moveAtNode:(id<JCSGameNode>)node {
    _node = node;
    _count = 0;
    NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:_depth];
    NSDate *start = [NSDate date];
    
    float score = [self negaScoutWithDepth:_depth alpha:-INFINITY beta:INFINITY principalVariation:pv];
    
    NSLog(@"analyzed %u nodes in %.3f seconds, got principal variation [%@] with score %.3f%@",
          _count, [[NSDate date] timeIntervalSinceDate:start], [pv componentsJoinedByString:@", "], score, _canceled ? @" (canceled)" : @"");
    
    return [pv count] > 0 ? pv[0] : nil;
}

- (float)negaScoutWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta principalVariation:(NSMutableArray *)principalVariation {
    _count++;
    
    if (depth == 0 || _node.leaf) {
        // maximum depth reached, or leaf node - take the node's heuristic value
        return [_heuristic valueOfNode:_node];
    }
    
    @autoreleasepool {
        NSArray *moves = [self possibleMoves];
        NSMutableArray *pv = [NSMutableArray arrayWithCapacity:depth-1];
        float bestScore;
        BOOL first = YES;
        for (id<JCSMove> move in moves) {
            @try {
                float score;
                [_node pushMove:move];
                // skip minimal-window search for first move
                if (!first) {
                    // search with minimal window
                    score = -[self negaScoutWithDepth:depth-1 alpha:-alpha-1 beta:-alpha principalVariation:pv];
                    if (score > bestScore) {
                        // improved
                        [principalVariation setArray:pv];
                        [principalVariation insertObject:move atIndex:0];
                        bestScore = score;
                    }
                    if (score >= beta) {
                        // no further improvement necessary
                        break;
                    }
                }
                if (first || score > alpha) {
                    // perform full-window search (the only search for first move)
                    score = -[self negaScoutWithDepth:depth-1 alpha:-beta beta:-alpha principalVariation:pv];
                    if (first || score > bestScore) {
                        // improved (or first move)
                        [principalVariation setArray:pv];
                        [principalVariation insertObject:move atIndex:0];
                        bestScore = score;
                        first = NO;
                    }
                    if (score >= beta) {
                        // no further improvement necessary
                        break;
                    }
                    if (score > alpha) {
                        // new lower bound
                        alpha = score;
                    }
                }
            } @finally {
                [_node popMove];
            }

            // check for cancellation
            if (_canceled) {
                break;
            }
        }
        
        return bestScore;
    }
}

- (NSArray *)possibleMoves {
    NSMutableArray *result = [NSMutableArray array];
    
    // determine possible moves and set their value for sorting
    [_node applyAllPossibleMovesAndInvokeBlock:^BOOL(id<JCSMove> move) {
        move.value = [_heuristic valueOfNode:_node];
        [result addObject:move];
        return YES;
    }];
    
    // sort by move value
    // the "best" move is the one with the lowest value, because it indicates the other player's advantage on the modified board
    return [result sortedArrayUsingSelector:@selector(compareByValueTo:)];
}

- (void)cancel {
    _canceled = YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(NegaScout Algorithm; %@; Depth %u)", _heuristic, _depth];
}

@end
