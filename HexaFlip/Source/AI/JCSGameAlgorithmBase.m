//
//  JCSGameAlgorithmBase.m
//  HexaFlip
//
//  Created by Christian Schuster on 27.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

#import "JCSGameAlgorithmBase.h"
#import "JCSMove.h"
#import "JCSGameNode.h"

typedef struct JCSGameAlgorithmBaseMoveValueEntry {
    float value;
    const void *move;
} JCSGameAlgorithmBaseMoveValueEntry;

@implementation JCSGameAlgorithmBase;

@synthesize canceled = _canceled;

- (instancetype)init {
    if (self = [super init]) {
        _canceled = NO;
    }
    return self;
}

- (void)applyPossibleMovesToNode:(id<JCSGameNode>)node sortByValue:(float(^)(id<JCSMove> move))valueProvider invokeBlock:(BOOL(^)(id<JCSMove> move))block {
    // pre-allocate moves
    NSInteger __block capacity = 16;
    JCSGameAlgorithmBaseMoveValueEntry __block *moves = (JCSGameAlgorithmBaseMoveValueEntry *)calloc(capacity, sizeof(JCSGameAlgorithmBaseMoveValueEntry));
    
    // determine possible moves and determine their value for sorting
    NSInteger __block count = 0;
    [node applyAllPossibleMovesAndInvokeBlock:^(id<JCSMove> move) {
        // double capacity if required
        if (count >= capacity) {
            do {
                capacity *= 2;
            } while (count >= capacity);
            moves = (JCSGameAlgorithmBaseMoveValueEntry *)realloc(moves, capacity * sizeof(JCSGameAlgorithmBaseMoveValueEntry));
        }
        moves[count].value = valueProvider(move);
        moves[count++].move = (__bridge_retained void *)move;
        return YES;
    }];
    
    // sort by move value
    mergesort_b(moves, count, sizeof(JCSGameAlgorithmBaseMoveValueEntry), ^int(const void *entry1, const void *entry2) {
        float v1 = ((const JCSGameAlgorithmBaseMoveValueEntry *)entry1)->value;
        float v2 = ((const JCSGameAlgorithmBaseMoveValueEntry *)entry2)->value;
        return (v1 > v2) - (v1 < v2);
    });
    
    // push-invoke-pop for the sorted moves and release moves
    BOOL keepGoing = YES;
    for (NSInteger i = 0; i < count; i++) {
        id<JCSMove> move = (__bridge_transfer id<JCSMove>)moves[i].move;
        if (keepGoing) {
            [node pushMove:move];
            keepGoing &= !_canceled && block(move);
            [node popMove];
        }
    }
    free(moves);
}

- (void)cancel {
    _canceled = YES;
}

- (BOOL)canceled {
    return _canceled;
}

@end
