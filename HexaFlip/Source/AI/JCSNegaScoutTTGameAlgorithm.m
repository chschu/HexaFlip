//
//  JCSNegaScoutTTGameAlgorithm.m
//  HexaFlip
//
//  Created by Christian Schuster on 26.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSNegaScoutTTGameAlgorithm.h"
#import "JCSGameHeuristic.h"
#import "JCSGameNode.h"
#import "JCSMove.h"
#import "JCSTranspositionTable.h"

@implementation JCSNegaScoutTTGameAlgorithm {
    // the heuristic evaluation to be used
    id<JCSGameHeuristic> _heuristic;
    
    // the currently analyzed node (modified during tree traversal)
    id<JCSGameNode> _node;
    
    // number of analyzed nodes (for stat output)
    NSUInteger _count;
    
    // search depth
    NSUInteger _depth;
    
    // transposition table
    JCSTranspositionTable *_transpositionTable;
}

- (instancetype)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic transpositionTable:(JCSTranspositionTable *)transpositionTable {
    NSAssert(depth > 0, @"depth must be positive");
    NSAssert(heuristic != nil, @"heuristic must not be nil");
    NSAssert(transpositionTable != nil, @"transposition table not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
        _transpositionTable = transpositionTable;
    }
    return self;
}

- (id<JCSMove>)moveAtNode:(id<JCSGameNode>)node {
    _node = node;
    _count = 0;
    id<JCSMove> bestMove = nil;
    NSDate *start = [NSDate date];
    
    float score = [self negaScoutWithDepth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove];
    
    NSLog(@"analyzed %lu nodes in %.3f seconds, got best move %@ with score %.3f%@",
          (unsigned long)_count, [[NSDate date] timeIntervalSinceDate:start], bestMove, score, self.canceled ? @" (canceled)" : @"");
    
    return bestMove;
}

- (float)negaScoutWithDepth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta bestMoveHolder:(id<JCSMove> __strong *)bestMoveHolder{
    _count++;
    
    if (depth == 0 || _node.leaf) {
        // maximum depth reached, or leaf node - take the node's heuristic value
        return [_heuristic valueOfNode:_node];
    }
    
    // check the transposition table only if the best move is not relevant
    float value;
    if (bestMoveHolder == nil && [_transpositionTable probeWithNode:_node depth:depth alpha:alpha beta:beta valueHolder:&value]) {
        return value;
    }
    
    float __block localAlpha = alpha;
    id<JCSMove> __block bestMove;
    float __block bestScore;
    BOOL __block first = YES;
    
    // store new alpha bound if nothing else is found
    JCSTranspositionTableEntryType __block transpositionTableEntryType = JCSTranspositionTableEntryTypeAlpha;
    
    @autoreleasepool {
        [self applyPossibleMovesToNode:_node sortByValue:^float(id<JCSMove> move) {
            return [_heuristic valueOfNode:_node];
        } invokeBlock:^BOOL(id<JCSMove> move) {
            float score;
            // skip minimal-window search for first move
            if (!first) {
                // search with minimal window
                score = -[self negaScoutWithDepth:depth-1 alpha:-localAlpha-1 beta:-localAlpha bestMoveHolder:nil];
                if (score > bestScore) {
                    // improved
                    bestMove = move;
                    bestScore = score;
                    transpositionTableEntryType = JCSTranspositionTableEntryTypeExact;
                }
                if (score >= beta) {
                    // no further improvement necessary
                    transpositionTableEntryType = JCSTranspositionTableEntryTypeBeta;
                    return NO;
                }
            }
            if (first || score > localAlpha) {
                // perform full-window search (the only search for first move)
                score = -[self negaScoutWithDepth:depth-1 alpha:-beta beta:-localAlpha bestMoveHolder:nil];
                if (first || score > bestScore) {
                    // improved (or first move)
                    bestMove = move;
                    bestScore = score;
                    transpositionTableEntryType = JCSTranspositionTableEntryTypeExact;
                    first = NO;
                }
                if (score >= beta) {
                    // no further improvement necessary
                    transpositionTableEntryType = JCSTranspositionTableEntryTypeBeta;
                    return NO;
                }
                if (score > localAlpha) {
                    // new lower bound
                    localAlpha = score;
                }
            }
            return YES;
        }];
        
        if (bestMoveHolder != nil) {
            *bestMoveHolder = bestMove;
        }
        
        // update transposition table only if computation is complete
        if (!self.canceled) {
            [_transpositionTable storeWithNode:_node depth:depth type:transpositionTableEntryType value:bestScore];
        }
        
        return bestScore;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(NegaScout Algorithm; %@; %@; Depth %lu)", _transpositionTable, _heuristic, (unsigned long)_depth];
}

@end
