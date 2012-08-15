//
//  JCSMinimaxGameAlgorithm.m
//  Flip
//
//  Created by Christian Schuster on 21.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSMinimaxGameAlgorithm.h"

// simple container class for move ordering
@interface JCSMinimaxChildData : NSObject {
@package
    // the move
    id move;

    // the child's heuristic value (used for move ordering)
    float childHeuristicValue;
}
@end

@implementation JCSMinimaxChildData
@end

@implementation JCSMinimaxGameAlgorithm {
    // the heuristic evaluation to be used
    id<JCSGameHeuristic> _heuristic;

    // the currently analyzed node (modified during tree traversal)
    id<JCSGameNode> _node;
    
    // number of analyzed nodes (for stat output)
    NSInteger _count;
}

@synthesize depth = _depth;

- (id)initWithDepth:(NSInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic {
	NSAssert(depth > 0, @"depth must be positive");
	NSAssert(heuristic != nil, @"heuristic must not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
    }
    return self;
}

- (id)moveAtNode:(id<JCSGameNode>)node {
    float score;
    id bestMove = nil;
    
    _node = node;
    
    _count = 0;
    NSDate *start = [NSDate date];
    
    if (node.maximizing) {
        score = [self maximizeWithDepth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove currentHeuristicValue:[_heuristic valueOfNode:node]];
    } else {
        score = [self minimizeWithDepth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove currentHeuristicValue:[_heuristic valueOfNode:node]];
    }
    
    NSLog(@"analyzed %d nodes in %.3f seconds, got best move %@ with score %.3f", _count, [[NSDate date] timeIntervalSinceDate:start], bestMove, score);
    
    return bestMove;
}

- (float)maximizeWithDepth:(NSInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder currentHeuristicValue:(float)heuristicValue {
    _count++;
	id bestMove = nil;
	float bestScore = -INFINITY;
    
    if (depth > 0 && !_node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenAscending:NO];
            for (JCSMinimaxChildData *entry in entries) {
                
                [_node pushMove:entry->move];
                float score = [self minimizeWithDepth:depth-1 alpha:alpha beta:beta bestMoveHolder:nil currentHeuristicValue:entry->childHeuristicValue];
                [_node popMove];
                
                if (score > bestScore || bestMove == nil) {
                    bestMove = entry->move;
                    bestScore = score;
                    if (score > alpha) {
                        alpha = score;
                    }
                    if (score >= beta) {
                        break;
                    }
                }
            }
        }
        NSAssert(bestMove != nil, @"must have a best move");
    } else {
        // maximum depth reached, or leaf node - take the node's heuristic value
        bestScore = heuristicValue;
    }
    
    if (bestMoveHolder != nil) {
        *bestMoveHolder = bestMove;
    }
    
    return bestScore;
}

- (float)minimizeWithDepth:(NSInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder currentHeuristicValue:(float)heuristicValue {
    _count++;
	id bestMove = nil;
	float bestScore = INFINITY;

    if (depth > 0 && !_node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenAscending:YES];
            for (JCSMinimaxChildData *entry in entries) {
                
                [_node pushMove:entry->move];
                float score = [self maximizeWithDepth:depth-1 alpha:alpha beta:beta bestMoveHolder:nil currentHeuristicValue:entry->childHeuristicValue];
                [_node popMove];
                
                if (score < bestScore || bestMove == nil) {
                    bestMove = entry->move;
                    bestScore = score;
                    if (score < beta) {
                        beta = score;
                    }
                    if (score <= alpha) {
                        break;
                    }
                }
            }
        }
        NSAssert(bestMove != nil, @"must have a best move");
    } else {
        // maximum depth reached, or leaf node - take the node's heuristic value
        bestScore = heuristicValue;
    }
    
    if (bestMoveHolder != nil) {
        *bestMoveHolder = bestMove;
    }
    
    return bestScore;
}

- (NSArray *)sortedChildrenAscending:(BOOL)ascending {
    NSMutableArray *result = [NSMutableArray array];
    
    [_node applyAllPossibleMovesAndInvokeBlock:^(id move, BOOL *stop) {
        JCSMinimaxChildData *entry = [[JCSMinimaxChildData alloc] init];
        entry->move = move;
        entry->childHeuristicValue = [_heuristic valueOfNode:_node];
        [result addObject:entry];
    }];

    NSComparisonResult(^comparator)(JCSMinimaxChildData *, JCSMinimaxChildData *);
    
    if (ascending) {
        comparator = ^NSComparisonResult(JCSMinimaxChildData *obj1, JCSMinimaxChildData *obj2) {
            float v1 = obj1->childHeuristicValue;
            float v2 = obj2->childHeuristicValue;
            if (v1 < v2) {
                return NSOrderedAscending;
            }
            if (v1 > v2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        };
    } else {
        comparator = ^NSComparisonResult(JCSMinimaxChildData *obj1, JCSMinimaxChildData *obj2) {
            float v1 = obj1->childHeuristicValue;
            float v2 = obj2->childHeuristicValue;
            if (v1 > v2) {
                return NSOrderedAscending;
            }
            if (v1 < v2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        };
    }
    
    return [result sortedArrayUsingComparator:comparator];
}

@end
