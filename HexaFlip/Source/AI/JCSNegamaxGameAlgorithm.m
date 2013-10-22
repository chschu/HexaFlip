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
    
    float score = [self negamaxWithDepth:_depth alpha:-INFINITY beta:INFINITY principalVariation:pv];
    
    NSLog(@"analyzed %u nodes in %.3f seconds, got principal variation [%@] with score %.3f%@",
          _count, [[NSDate date] timeIntervalSinceDate:start], [pv componentsJoinedByString:@", "], score, _canceled ? @" (canceled)" : @"");
    
    return [pv count] > 0 ? [pv objectAtIndex:0] : nil;
}

- (float)negamaxWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta principalVariation:(NSMutableArray *)principalVariation {
    _count++;
    
    if (depth > 0 && !_node.leaf) {
        @autoreleasepool {
            NSArray *moves = [self possibleMoves];
            NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:depth-1];
            BOOL first = YES;
            for (id<JCSMove> move in moves) {
                
                [_node pushMove:move];
                float score = -[self negamaxWithDepth:depth-1 alpha:-beta beta:-alpha principalVariation:pv];
                [_node popMove];
                
                if (score > alpha) {
                    first = NO;
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:move atIndex:0];
                    alpha = score;
                    if (alpha >= beta) {
                        break;
                    }
                } else if (first) {
                    // keep first move, just in case there are only really bad moves
                    first = NO;
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:move atIndex:0];
                }
                
                // check for cancellation
                if (_canceled) {
                    break;
                }
            }
        }
    } else {
        // maximum depth reached, or leaf node - take the node's heuristic value
        alpha = [_heuristic valueOfNode:_node];
    }
    
    return alpha;
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
