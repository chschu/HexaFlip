//
//  JCSTranspositionTable.h
//  HexaFlip
//
//  Created by Christian Schuster on 25.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

@protocol JCSGameNode;

typedef NS_ENUM(NSInteger, JCSTranspositionTableEntryType) {
    JCSTranspositionTableEntryTypeExact,
    JCSTranspositionTableEntryTypeAlpha,
    JCSTranspositionTableEntryTypeBeta,
};

@interface JCSTranspositionTable : NSObject

// initialize a transposition table with the given number of slots
- (instancetype)initWithSize:(NSUInteger)size;

// check if the transposition table contains a reliable entry for the given node, minimum required search depth, and the current alpha and beta
// returns NO if no reliable entry could be found
// if the return value is YES, the corresponding node value is stored in the valueHolder (unless the valueHolder is nil)
- (BOOL)probeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta valueHolder:(float *)valueHolder;

// store a value in the transposition table, given a node, search depth and entry type
- (void)storeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth type:(JCSTranspositionTableEntryType)type value:(float)value;

@end
