//
//  JCSTranspositionTable.h
//  HexaFlip
//
//  Created by Christian Schuster on 25.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

@protocol JCSMove;
@protocol JCSGameNode;

typedef enum {
    JCSTranspositionTableEntryTypeExact,
    JCSTranspositionTableEntryTypeAlpha,
    JCSTranspositionTableEntryTypeBeta,
} JCSTranspositionTableEntryType;

@interface JCSTranspositionTable : NSObject

// initialize a transposition table with the given number of slots
- (id)initWithSize:(NSUInteger)size;

// check if the transposition table contains a reliable entry for the given node, minimum required search depth, and the current alpha and beta
// returns nil if no reliable entry could be found
// if the return value is not nil, the corresponding node value is stored in the valueHolder (unless the valueHolder is nil)
- (id<JCSMove>)probeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta valueHolder:(float *)valueHolder;

// store a move and value combination in the transposition table, given a node, search depth, and entry type
- (void)storeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth type:(JCSTranspositionTableEntryType)type value:(float)value bestMove:(id<JCSMove>)bestMove;

@end
