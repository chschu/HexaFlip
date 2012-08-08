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
    // the child node
    id<JCSGameNode> child;
    
    // the child's heuristic value (used for move ordering)
    float childHeuristicValue;
    
    // the move
    id move;
}
@end

@implementation JCSMinimaxChildData
@end

@implementation JCSMinimaxGameAlgorithm {
    // the heuristic evaluation to be used
    id<JCSGameHeuristic> _heuristic;

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
    
    _count = 0;
    NSDate *start = [NSDate date];
    
    if (node.maximizing) {
        score = [self maximizeForNode:node heuristicValue:[_heuristic valueOfNode:node] depth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove];
    } else {
        score = [self minimizeForNode:node heuristicValue:[_heuristic valueOfNode:node] depth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove];
    }
    
    NSLog(@"analyzed %d nodes in %.3f seconds", _count, [[NSDate date] timeIntervalSinceDate:start]);
    
    return bestMove;
}

- (float)maximizeForNode:(id<JCSGameNode>)node heuristicValue:(float)heuristicValue depth:(NSInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder {
    _count++;
	id bestMove = nil;
	float bestScore = -INFINITY;
    
    if (depth > 0 && !node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenOfNode:node ascending:NO];
            for (JCSMinimaxChildData *entry in entries) {
                float score = [self minimizeForNode:entry->child heuristicValue:entry->childHeuristicValue depth:depth-1 alpha:alpha beta:beta bestMoveHolder:nil];
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

- (float)minimizeForNode:(id<JCSGameNode>)node heuristicValue:(float)heuristicValue depth:(NSInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder {
    _count++;
	id bestMove = nil;
	float bestScore = INFINITY;
    
    if (depth > 0 && !node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenOfNode:node ascending:YES];
            for (JCSMinimaxChildData *entry in entries) {
                float score = [self maximizeForNode:entry->child heuristicValue:entry->childHeuristicValue depth:depth-1 alpha:alpha beta:beta bestMoveHolder:nil];
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

- (NSArray *)sortedChildrenOfNode:(id<JCSGameNode>)node ascending:(BOOL)ascending {
    NSMutableArray *result = [NSMutableArray array];
    
    [node enumerateChildrenUsingBlock:^(id move, id<JCSGameNode> child, BOOL *stop) {
        JCSMinimaxChildData *entry = [[JCSMinimaxChildData alloc] init];
        entry->child = child;
        entry->childHeuristicValue = [_heuristic valueOfNode:child];
        entry->move = move;
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
