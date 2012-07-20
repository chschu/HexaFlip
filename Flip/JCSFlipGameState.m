//
//  JCSFlipGameState.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"

@implementation JCSFlipGameState {
    // cell states for all cells in the grid 
    // keys: (JCSHexCoordinate *)
    // values: (NSNumber *) wrapper around JCSFlipCellState
    NSMutableDictionary *_cellStates;
}

@synthesize playerToMove = _playerToMove;
@synthesize score = _score;

#pragma mark instance methods

// private designated initializer
- (id)initWithPlayerToMove:(JCSFlipPlayer)playerToMove cellStates:(NSMutableDictionary *)cellStates {
	if (self = [super init]) {
        _playerToMove = playerToMove;
		_cellStates = cellStates;
	}
	return self;
}

- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayer)playerToMove cellAtBlock:(BOOL (^)(JCSHexCoordinate *))cellAtBlock cellStateAtBlock:(JCSFlipCellState (^)(JCSHexCoordinate *))cellStateAtBlock {
	NSAssert(size >= 0, @"size must be non-negative");
	NSAssert(cellAtBlock != nil, @"cellAt block must not be nil");
	NSAssert(cellStateAtBlock != nil, @"cellStateAt block must not be nil");
    
	NSMutableDictionary *cellStates = [NSMutableDictionary dictionary];
	for (int row = -size+1; row < size; row++) {
		for (int column = -size+1; column < size; column++) {
			JCSHexCoordinate *coordinate = [JCSHexCoordinate hexCoordinateWithRow:row column:column];
			if (cellAtBlock(coordinate)) {
				JCSFlipCellState cellState = cellStateAtBlock(coordinate);
				[cellStates setObject:[NSNumber numberWithInt:cellState] forKey:coordinate];
			}
		}
	}
	
	return [self initWithPlayerToMove:playerToMove cellStates:cellStates];
}

- (void)forAllCellsInvokeBlock:(void(^)(JCSHexCoordinate *coordinate, JCSFlipCellState cellState, BOOL *stop))block {
	[_cellStates enumerateKeysAndObjectsUsingBlock:^(JCSHexCoordinate *key, NSNumber *obj, BOOL *stop) {
		block(key, [obj intValue], stop);
	}];
    
}

- (BOOL)hasCellAt:(JCSHexCoordinate *)coordinate {
    return [_cellStates objectForKey:coordinate] != nil;
}

- (JCSFlipCellState)cellStateAt:(JCSHexCoordinate *)coordinate {
    NSNumber *cellStateAsNumber = [_cellStates objectForKey:coordinate];
    NSAssert(cellStateAsNumber != nil, @"cellStateAt may only be invoked for existing cells");
    return [cellStateAsNumber intValue];
}

// - (BOOL)applyMove:(JCSFlipMove *)move {
// }

#pragma mark AI methods

// - (void)forAllNextStatesInvoke:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block {
// }

// - (NSInteger)score {
// }

#pragma mark NSCopying methods

- (id)copyWithZone:(NSZone *)zone {
	// create a new instance, using a mutable copy of the cell state dictionary 
	return [[[self class] allocWithZone:zone] initWithPlayerToMove:_playerToMove cellStates:[_cellStates mutableCopyWithZone:zone]];
}

@end
