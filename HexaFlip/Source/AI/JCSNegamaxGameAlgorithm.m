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

// simple container class for move ordering
@interface JCSNegamaxChildData : NSObject {
    @package
    // the move
    id move;
    
    // the child's heuristic value (used for move ordering)
    float childHeuristicValue;
}

- (NSComparisonResult)compareTo:(JCSNegamaxChildData *)other;

@end

@implementation JCSNegamaxChildData

- (NSComparisonResult)compareTo:(JCSNegamaxChildData *)other {
    float v1 = self->childHeuristicValue;
    float v2 = other->childHeuristicValue;
    if (v1 < v2) {
        return NSOrderedAscending;
    }
    if (v1 > v2) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

@end

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

- (id)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic {
	NSAssert(depth > 0, @"depth must be positive");
	NSAssert(heuristic != nil, @"heuristic must not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
    }
    return self;
}

- (id)moveAtNode:(id<JCSGameNode>)node {
    id bestMove = nil;
    _node = node;
    
    _count = 0;
    NSDate *start = [NSDate date];
    
    float score = [self negamaxWithDepth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove currentHeuristicValue:[_heuristic valueOfNode:node]];
    
    NSLog(@"analyzed %u nodes in %.3f seconds, got best move %@ with score %.3f", _count, [[NSDate date] timeIntervalSinceDate:start], bestMove, score);
    
    return bestMove;
}

- (float)negamaxWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id *)bestMoveHolder currentHeuristicValue:(float)heuristicValue {
    _count++;
	id bestMove = nil;
    
    if (depth > 0 && !_node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenAscending];
            for (JCSNegamaxChildData *entry in entries) {
                
                [_node pushMove:entry->move];
                float score = -[self negamaxWithDepth:depth-1 alpha:-beta beta:-alpha bestMoveHolder:nil currentHeuristicValue:entry->childHeuristicValue];
                [_node popMove];
                
                if (score > alpha) {
                    bestMove = entry->move;
                    alpha = score;
                    if (alpha >= beta) {
                        break;
                    }
                } else if (bestMove == nil) {
                    // keep first move, just in case there are only really bad moves
                    bestMove = entry->move;
                }
            }
        }
        NSAssert(bestMove != nil, @"must have a best move");
    } else {
        // maximum depth reached, or leaf node - take the node's heuristic value
        alpha = heuristicValue;
    }
    
    if (bestMoveHolder != nil) {
        *bestMoveHolder = bestMove;
    }
    
    return alpha;
}

- (NSArray *)sortedChildrenAscending {
    NSMutableArray *result = [NSMutableArray array];
    
    [_node applyAllPossibleMovesAndInvokeBlock:^(id move, BOOL *stop) {
        JCSNegamaxChildData *entry = [[JCSNegamaxChildData alloc] init];
        entry->move = move;
        entry->childHeuristicValue = [_heuristic valueOfNode:_node];
        [result addObject:entry];
    }];
    
    return [result sortedArrayUsingSelector:@selector(compareTo:)];
}

@end
