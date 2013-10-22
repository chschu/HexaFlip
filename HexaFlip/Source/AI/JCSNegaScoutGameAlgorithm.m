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

- (id)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic {
	NSAssert(depth > 0, @"depth must be positive");
	NSAssert(heuristic != nil, @"heuristic must not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
        _canceled = NO;
    }
    return self;
}

- (id)moveAtNode:(id<JCSGameNode>)node {
    _node = node;
    _count = 0;
    NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:_depth];
    NSDate *start = [NSDate date];
    
    float score = [self negaScoutWithDepth:_depth alpha:-INFINITY beta:INFINITY principalVariation:pv];
    
    NSLog(@"analyzed %u nodes in %.3f seconds, got principal variation [%@] with score %.3f%@",
          _count, [[NSDate date] timeIntervalSinceDate:start], [pv componentsJoinedByString:@", "], score, _canceled ? @" (canceled)" : @"");
    
    return [pv count] > 0 ? [pv objectAtIndex:0] : nil;
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
        
        // first move always exists (node is not a leaf)
        id<JCSMove> move = [moves objectAtIndex:0];
        
        [_node pushMove:move];
        float bestScore = -[self negaScoutWithDepth:depth-1 alpha:-beta beta:-alpha principalVariation:pv];
        [_node popMove];
        
        // always initialize principal variation with first move, in case there are only bad moves or the search is cancelled
        [principalVariation setArray:pv];
        [principalVariation insertObject:move atIndex:0];
        
        if (bestScore >= beta) {
            // no further improvement necessary
            return bestScore;
        }
        if (bestScore > alpha) {
            // new lower bound
            alpha = bestScore;
        }
        
        for (move in [moves subarrayWithRange:NSMakeRange(1, [moves count]-1)]) {
            // check for cancellation
            if (_canceled) {
                break;
            }
            
            @try {
                [_node pushMove:move];
                // search with minimal window
                float score = -[self negaScoutWithDepth:depth-1 alpha:-alpha-1 beta:-alpha principalVariation:pv];
                if (score > bestScore) {
                    // improved
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:move atIndex:0];
                    bestScore = score;
                }
                if (score >= beta) {
                    // no further improvement necessary
                    return score;
                }
                if (score > alpha) {
                    // need to repeat search with full window
                    score = -[self negaScoutWithDepth:depth-1 alpha:-beta beta:-alpha principalVariation:pv];
                    if (score > bestScore) {
                        // improved
                        [principalVariation setArray:pv];
                        [principalVariation insertObject:move atIndex:0];
                        bestScore = score;
                    }
                    if (score >= beta) {
                        // no further improvement necessary
                        return score;
                    }
                    if (score > alpha) {
                        // new lower bound
                        alpha = score;
                    }
                }
            } @finally {
                [_node popMove];
            }
        }
        
        return bestScore;
    }
}

- (NSArray *)possibleMoves {
    NSMutableArray *result = [NSMutableArray array];
    
    // determine possible moves and set their value for sorting
    [_node applyAllPossibleMovesAndInvokeBlock:^(id<JCSMove> move, BOOL *stop) {
        move.value = [_heuristic valueOfNode:_node];
        [result addObject:move];
    }];
    
    // sort by move value
    // the "best" move is the one with the lowest value, because it indicates the other player's advantage on the modified board
    return [result sortedArrayUsingSelector:@selector(compareByValueTo:)];
}

- (void)cancel {
    _canceled = YES;
}

@end
