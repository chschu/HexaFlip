//
//  JCSTranspositionTable.m
//  HexaFlip
//
//  Created by Christian Schuster on 25.10.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSTranspositionTable.h"
#import "JCSGameNode.h"
#import "JCSMove.h"

@interface JCSTranspositionTableEntry : NSObject {
    @package
    // Zobrist hash of the state
    NSUInteger _zobristHash;
    // remaining search depth
    NSUInteger _depth;
    // entry type
    JCSTranspositionTableEntryType _type;
    // entry value
    float _value;
    // best move computed for that state
    id<JCSMove> _bestMove;
}
@end

@implementation JCSTranspositionTableEntry
@end

@implementation JCSTranspositionTable {
    // table size
    NSUInteger _size;
    // transposition table (index: zobrist hash modulo size)
    JCSTranspositionTableEntry * __strong *_transpositionTable;
}

- (id)initWithSize:(NSUInteger)size {
    if (self = [super init]) {
        _size = size;
        _transpositionTable = (JCSTranspositionTableEntry * __strong *) calloc(_size, sizeof(JCSTranspositionTableEntry *));
    }
    return self;
}

- (void)dealloc {
    // zero references to release the entries
    for (int i = 0; i < _size; i++) {
        _transpositionTable[i] = 0;
    }
    free(_transpositionTable);
}

- (id<JCSMove>)probeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth alpha:(float)alpha beta:(float)beta valueHolder:(float *)valueHolder {
    NSUInteger key = node.zobristHash % _size;
    JCSTranspositionTableEntry *entry = _transpositionTable[key];
    
    // if we have no entry, return nothing
    if (entry == nil) {
        return nil;
    }
    
    // if the hash values mismatch, return nothing
    if (entry->_zobristHash != node.zobristHash) {
        return nil;
    }
    
    // if entry depth is to low, return nothing
    if (entry->_depth < depth) {
        return nil;
    }
    
    // if entry type gives valid restriction, return it
    if (entry->_type == JCSTranspositionTableEntryTypeExact
        || (entry->_type == JCSTranspositionTableEntryTypeAlpha && entry->_value <= alpha)
        || (entry->_type == JCSTranspositionTableEntryTypeBeta && entry->_value >= beta)) {
        if (valueHolder != nil) {
            *valueHolder = entry->_value;
        }
        return entry->_bestMove;
    }
    
    // no valid restriction, return nothing
    return nil;
    
}

- (void)storeWithNode:(id<JCSGameNode>)node depth:(NSUInteger)depth type:(JCSTranspositionTableEntryType)type value:(float)value bestMove:(id<JCSMove>)bestMove {
    NSUInteger key = node.zobristHash % _size;
    JCSTranspositionTableEntry *entry = [JCSTranspositionTableEntry new];
    
    entry->_zobristHash = node.zobristHash;
    entry->_depth = depth;
    entry->_type = type;
    entry->_value = value;
    entry->_bestMove = bestMove;
    
    // TODO overwrite only worse entries, e.g. ones with smaller depth
    _transpositionTable[key] = entry;
}

@end
