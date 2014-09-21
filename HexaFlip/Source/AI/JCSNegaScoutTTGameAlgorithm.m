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
    
    // the indicator for cancellation
    volatile BOOL _canceled;
}

- (instancetype)initWithDepth:(NSUInteger)depth heuristic:(id<JCSGameHeuristic>)heuristic transpositionTable:(JCSTranspositionTable *)transpositionTable {
	NSAssert(depth > 0, @"depth must be positive");
	NSAssert(heuristic != nil, @"heuristic must not be nil");
	NSAssert(transpositionTable != nil, @"transposition table not be nil");
    
    if (self = [super init]) {
        _depth = depth;
        _heuristic = heuristic;
        _transpositionTable = transpositionTable;
        _canceled = NO;
    }
    return self;
}

- (id<JCSMove>)moveAtNode:(id<JCSGameNode>)node {
    _node = node;
    _count = 0;
    id<JCSMove> bestMove = nil;
    NSDate *start = [NSDate date];
    
    float score = [self negaScoutWithDepth:_depth alpha:-INFINITY beta:INFINITY bestMoveHolder:&bestMove];
    
    NSLog(@"analyzed %u nodes in %.3f seconds, got best move %@ with score %.3f%@",
          _count, [[NSDate date] timeIntervalSinceDate:start], bestMove, score, _canceled ? @" (canceled)" : @"");
    
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
    
    @autoreleasepool {
        NSArray *moves = [self possibleMoves];
        
        // store new alpha bound if nothing else is found
        JCSTranspositionTableEntryType transpositionTableEntryType = JCSTranspositionTableEntryTypeAlpha;
        
        id<JCSMove> bestMove;
        float bestScore;
        BOOL first = YES;
        
        for (id<JCSMove> move in moves) {
            @try {
                float score;
                [_node pushMove:move];
                // skip minimal-window search for first move
                if (!first) {
                    // search with minimal window
                    score = -[self negaScoutWithDepth:depth-1 alpha:-alpha-1 beta:-alpha bestMoveHolder:nil];
                    if (score > bestScore) {
                        // improved
                        bestMove = move;
                        bestScore = score;
                        transpositionTableEntryType = JCSTranspositionTableEntryTypeExact;
                    }
                    if (score >= beta) {
                        // no further improvement necessary
                        transpositionTableEntryType = JCSTranspositionTableEntryTypeBeta;
                        break;
                    }
                }
                if (first || score > alpha) {
                    // perform full-window search (the only search for first move)
                    score = -[self negaScoutWithDepth:depth-1 alpha:-beta beta:-alpha bestMoveHolder:nil];
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
        
        if (bestMoveHolder != nil) {
            *bestMoveHolder = bestMove;
        }
        
        // update transposition table only if computation is complete
        if (!_canceled) {
            [_transpositionTable storeWithNode:_node depth:depth type:transpositionTableEntryType value:bestScore];
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
    return [NSString stringWithFormat:@"(NegaScout Algorithm; %@; %@; Depth %u)", _transpositionTable, _heuristic, _depth];
}

@end
