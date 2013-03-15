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
    
    // the sort criterion for move ordering
    float criterion;
}

- (NSComparisonResult)compareTo:(JCSNegamaxChildData *)other;

@end

@implementation JCSNegamaxChildData

- (NSComparisonResult)compareTo:(JCSNegamaxChildData *)other {
    float v1 = self->criterion;
    float v2 = other->criterion;
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
          _count, [[NSDate date] timeIntervalSinceDate:start], [self stringForPrincipalVariation:pv], score, _canceled ? @" (canceled)" : @"");
    
    return [pv count] > 0 ? [pv objectAtIndex:0] : nil;
}

- (NSString *)stringForPrincipalVariation:(NSArray *)principalVariation {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (id move in principalVariation) {
        if (result.length > 0) {
            [result appendString:@", "];
        }
        [result appendString:[move description]];
    }
    return result;
}

- (float)negamaxWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta principalVariation:(NSMutableArray *)principalVariation {
    _count++;
    
    if (depth > 0 && !_node.leaf) {
        @autoreleasepool {
            NSArray *entries = [self sortedChildrenAscending];
            NSMutableArray *pv = [[NSMutableArray alloc] initWithCapacity:depth-1];
            BOOL first = YES;
            for (JCSNegamaxChildData *entry in entries) {
                
                [_node pushMove:entry->move];
                float score = -[self negamaxWithDepth:depth-1 alpha:-beta beta:-alpha principalVariation:pv];
                [_node popMove];
                
                if (score > alpha) {
                    first = NO;
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:entry->move atIndex:0];
                    alpha = score;
                    if (alpha >= beta) {
                        break;
                    }
                } else if (first) {
                    // keep first move, just in case there are only really bad moves
                    first = NO;
                    [principalVariation setArray:pv];
                    [principalVariation insertObject:entry->move atIndex:0];
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

- (NSArray *)sortedChildrenAscending {
    NSMutableArray *result = [NSMutableArray array];
    
    [_node applyAllPossibleMovesAndInvokeBlock:^(id move, BOOL *stop) {
        JCSNegamaxChildData *entry = [[JCSNegamaxChildData alloc] init];
        entry->move = move;
        entry->criterion = [_heuristic valueOfNode:_node];
        [result addObject:entry];
    }];
    
    return [result sortedArrayUsingSelector:@selector(compareTo:)];
}

- (void)cancel {
    _canceled = YES;
}

@end
