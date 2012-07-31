//
//  JCSMinimaxGameAlgorithm.m
//  Flip
//
//  Created by Christian Schuster on 21.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSMinimaxGameAlgorithm.h"

@implementation JCSMinimaxGameAlgorithm {
    // the heuristic evaluation to be used
    id<JCSGameHeuristic> _heuristic;
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
    
    if (node.maximizing) {
        score = [self maximizeForNode:node depth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove];
    } else {
        score = [self minimizeForNode:node depth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove];
    }
    
    return bestMove;
}

- (float)maximizeForNode:(id<JCSGameNode>)node depth:(NSInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder {
	id bestMove = nil;
	float bestScore = -INFINITY;
    
    if (depth > 0 && !node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenOfNode:node ascending:NO];
            for (NSArray *entry in entries) {
                id move = [entry objectAtIndex:1];
                id<JCSGameNode> child = [entry objectAtIndex:2];
                float score = [self minimizeForNode:child depth:depth-1 alpha:alpha beta:beta bestMoveHolder:nil];
                if (score > bestScore || bestMove == nil) {
                    bestMove = move;
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
        bestScore = [_heuristic valueOfNode:node];
    }
    
    if (bestMoveHolder != nil) {
        *bestMoveHolder = bestMove;
    }
    
    return bestScore;
}

- (float)minimizeForNode:(id<JCSGameNode>)node depth:(NSInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder {
	id bestMove = nil;
	float bestScore = INFINITY;
    
    if (depth > 0 && !node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenOfNode:node ascending:YES];
            for (NSArray *entry in entries) {
                id move = [entry objectAtIndex:1];
                id<JCSGameNode> child = [entry objectAtIndex:2];
                float score = [self maximizeForNode:child depth:depth-1 alpha:alpha beta:beta bestMoveHolder:nil];
                if (score < bestScore || bestMove == nil) {
                    bestMove = move;
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
        bestScore = [_heuristic valueOfNode:node];
    }
    
    if (bestMoveHolder != nil) {
        *bestMoveHolder = bestMove;
    }
    
    return bestScore;
}

- (NSArray *)sortedChildrenOfNode:(id<JCSGameNode>)node ascending:(BOOL)ascending {
    __block NSMutableArray *result = [NSMutableArray array];
    
    [node enumerateChildrenUsingBlock:^(id move, id<JCSGameNode> child, BOOL *stop) {
        float heuristicValue = [_heuristic valueOfNode:node];
        NSArray *entry = [NSArray arrayWithObjects:[NSNumber numberWithFloat:heuristicValue], move, child, nil];
        [result addObject:entry];
    }];
    
    NSComparisonResult(^comparator)(NSArray *, NSArray *);
    
    if (ascending) {
        comparator = ^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            NSNumber *score1 = [obj1 objectAtIndex:0];
            NSNumber *score2 = [obj2 objectAtIndex:0];
            return [score1 compare:score2];
        };
    } else {
        comparator = ^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            NSNumber *score1 = [obj1 objectAtIndex:0];
            NSNumber *score2 = [obj2 objectAtIndex:0];
            return [score2 compare:score1];
        };
    }
    
    return [result sortedArrayUsingComparator:comparator];
}

@end
