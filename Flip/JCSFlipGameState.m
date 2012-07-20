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

- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayer)playerToMove cellAtBlock:(BOOL (^)(JCSHexCoordinate *coordinate))cellAtBlock cellStateAtBlock:(JCSFlipCellState (^)(JCSHexCoordinate *coordinate))cellStateAtBlock {
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

// private accessor to set a cell state
- (void)setCellState:(JCSFlipCellState)cellState at:(JCSHexCoordinate *)coordinate {
    NSNumber *cellStateAsNumber = [NSNumber numberWithInt:cellState];
    [_cellStates setObject:cellStateAsNumber forKey:coordinate];
}

- (BOOL)applyMove:(JCSFlipMove *)move {
    JCSHexCoordinate *cur = move.start;
    
    // fail if the starting cell is not present
    if (![self hasCellAt:cur]) {
        return NO;
    }
    
    JCSFlipCellState startCellState = [self cellStateAt:cur];
    
    if (!((_playerToMove == JCSFlipPlayerA && startCellState == JCSFlipCellStateOwnedByPlayerA)
          || (_playerToMove == JCSFlipPlayerB && startCellState == JCSFlipCellStateOwnedByPlayerB))) {
        return NO;
    }
    
    JCSHexDirection direction = move.direction;
    
    // set to collect the cells to be flipped
    NSMutableArray *cellsToFlip = [NSMutableArray array];
    
    // scan in move direction until an empty cell or a "hole" is reached
    cur = [JCSHexCoordinate hexCoordinateWithHexCoordinate:cur direction:direction];
    while ([self hasCellAt:cur] && [self cellStateAt:cur] != JCSFlipCellStateEmpty) {
        [cellsToFlip addObject:cur];
        cur = [JCSHexCoordinate hexCoordinateWithHexCoordinate:cur direction:direction];
    }
    
    // fail if a "hole" is reached
    if (![self hasCellAt:cur]) {
        return NO;
    }
    
    // occupy target cell
    [self setCellState:startCellState at:cur];
    
    // flip intermediate cells
    for (JCSHexCoordinate *coordinate in cellsToFlip) {
        [self setCellState:JCSFlipCellStateOther([self cellStateAt:coordinate]) at:coordinate];
    }
    
    // switch players
    _playerToMove = JCSFlipPlayerOther(_playerToMove);
    
    // move successful
    return YES;
}

#pragma mark AI methods

- (void)forAllNextStatesInvoke:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block {
    NSAssert(block != nil, @"block must not be nil");
    
    JCSFlipCellState playerCellState = JCSFlipCellStateForPlayer(_playerToMove);
    
    [self forAllCellsInvokeBlock:^(JCSHexCoordinate *coordinate, JCSFlipCellState cellState, BOOL *stop) {
        // try cells with the correct owner as starting cells 
        if (cellState == playerCellState) {
            // try all directions, but stop if the block says to do so
            for (JCSHexDirection direction = JCSHexDirectionMin; direction <= JCSHexDirectionMax && !*stop; direction++) {
                JCSFlipMove *move = [JCSFlipMove moveWithStart:coordinate direction:direction];
                JCSFlipGameState *stateCopy = [self copy];
                if ([stateCopy applyMove:move]) {
                    // move is valid - invoke block
                    block(move, stateCopy, stop);
                }
            }
        }
    }];
}

- (NSInteger)score {
    NSAssert(NO, @"not yet implemented");
    return 0;
}

#pragma mark NSCopying methods

- (id)copyWithZone:(NSZone *)zone {
	// create a new instance, using a mutable copy of the cell state dictionary 
	return [[[self class] allocWithZone:zone] initWithPlayerToMove:_playerToMove cellStates:[_cellStates mutableCopyWithZone:zone]];
}

@end
