//
//  JCSTranspositionTable.m
//  HexaFlip
//
//  Created by Christian Schuster on 25.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSTranspositionTable.h"
#import "JCSGameNode.h"

typedef struct {
    // YES if the entry is valid
    BOOL valid;
    // Zobrist hash of the state
    NSUInteger zobristHash;
    // remaining search depth
    NSUInteger depth;
    // entry type
    JCSTranspositionTableEntryType type;
    // entry value
    float value;
} JCSTranspositionTableEntry;

@implementation JCSTranspositionTable {
    // table size
    NSUInteger _size;
    // transposition table (index: zobrist hash modulo size)
    JCSTranspositionTableEntry *_transpositionTable;
}

- (instancetype)initWithSize:(NSUInteger)size {
    if (self = [super init]) {
        _size = size;
        _transpositionTable = (JCSTranspositionTableEntry *) calloc(_size, sizeof(JCSTranspositionTableEntry));
    }
    return self;
}

- (void)dealloc {
    free(_transpositionTable);
}

- (BOOL)probeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta valueHolder:(float *)valueHolder {
    NSUInteger key = node.zobristHash % _size;
    JCSTranspositionTableEntry *entry = _transpositionTable + key;
    
    // if we have no entry, return nothing
    if (!entry->valid) {
        return NO;
    }
    
    // if the hash values mismatch, return nothing
    if (entry->zobristHash != node.zobristHash) {
        return NO;
    }
    
    // if entry depth is to low, return nothing
    if (entry->depth < depth) {
        return NO;
    }
    
    // if entry type gives valid restriction, return it
    if (entry->type == JCSTranspositionTableEntryTypeExact
        || (entry->type == JCSTranspositionTableEntryTypeAlpha && entry->value <= alpha)
        || (entry->type == JCSTranspositionTableEntryTypeBeta && entry->value >= beta)) {
        if (valueHolder != nil) {
            *valueHolder = entry->value;
        }
        return YES;
    }
    
    // no valid restriction, return nothing
    return NO;
    
}

- (void)storeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth type:(JCSTranspositionTableEntryType)type value:(float)value {
    NSUInteger key = node.zobristHash % _size;
    JCSTranspositionTableEntry *entry = _transpositionTable + key;
    
    // TODO (?) overwrite only worse entries, e.g. ones with smaller depth
    entry->valid = YES;
    entry->zobristHash = node.zobristHash;
    entry->depth = depth;
    entry->type = type;
    entry->value = value;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(Transposition Table; Size %lu)", (unsigned long)_size];
}

@end
