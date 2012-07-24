//
//  JCSFlipGameState.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipCellState.h"

@implementation JCSFlipGameState {
    // size of the grid
    // coordinates are between -(size-1) and (size-1), both inclusive
    NSInteger _size;
    
    // cell states for all cells in the grid, in row-major order
    // the state of the cell at (r,c) is stored at index size*(r+(size-1)) + c+(size-1)
    JCSFlipCellState *_cellStates;
}

@synthesize playerToMove = _playerToMove;

#pragma mark instance methods

// index into the cell states array
// parameters: row in [-(size-1),(size-1)], column in [-(size-1),(size-1)]
#define JCS_CELL_STATE_INDEX(row, column) ((2*_size-1)*((row)+(_size-1)) + (column)+(_size-1))

// designated initializer
- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayer)playerToMove cellStateAtBlock:(JCSFlipCellState (^)(NSInteger row, NSInteger column))cellStateAtBlock {
	NSAssert(size >= 0, @"size must be non-negative");
	NSAssert(cellStateAtBlock != nil, @"cellStateAt block must not be nil");
    
    if (self = [super init]) {
        _size = size;
        _playerToMove = playerToMove;
        _cellStates = malloc((2*_size-1)*(2*_size-1)*sizeof(JCSFlipCellState));
        NSInteger index = 0;
        for (NSInteger row = -size+1; row < size; row++) {
            for (NSInteger column = -size+1; column < size; column++) {
                _cellStates[index] = cellStateAtBlock(row, column);
                index++;
            }
        }
    }
	
	return self;
}

- (void)dealloc {
    free(_cellStates);
}

- (void)forAllCellsInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop))block {
    BOOL stop = NO;
    NSInteger index = 0;
    for (NSInteger row = -_size+1; row < _size && !stop; row++) {
        for (NSInteger column = -_size+1; column < _size && !stop; column++) {
            JCSFlipCellState cellState = _cellStates[index];
            if (cellState != JCSFlipCellStateHole) {
                block(row, column, cellState, &stop);
            }
            index++;
        }
    }
}

- (JCSFlipCellState)cellStateAtRow:(NSInteger)row column:(NSInteger)column {
    if (row <= -_size || row >= _size || column <= -_size || column >= _size) {
        return JCSFlipCellStateHole;
    }
    NSInteger index = JCS_CELL_STATE_INDEX(row, column);
    return _cellStates[index];
}

// private accessor to set a cell state (without range check)
- (void)setCellState:(JCSFlipCellState)cellState atRow:(NSInteger)row column:(NSInteger)column {
    NSInteger index = JCS_CELL_STATE_INDEX(row, column);
    _cellStates[index] = cellState;
}

- (BOOL)applyMove:(JCSFlipMove *)move {
    NSInteger startRow = move.startRow;
    NSInteger startColumn = move.startColumn;
    
    JCSFlipCellState startCellState = [self cellStateAtRow:startRow column:startColumn];
    
    if (!((_playerToMove == JCSFlipPlayerA && startCellState == JCSFlipCellStateOwnedByPlayerA)
          || (_playerToMove == JCSFlipPlayerB && startCellState == JCSFlipCellStateOwnedByPlayerB))) {
        return NO;
    }
    
    JCSHexDirection direction = move.direction;
    
    // determine row and column deltas
    NSInteger rowDelta = JCSHexDirectionRowDelta(direction);
    NSInteger columnDelta = JCSHexDirectionColumnDelta(direction);
    
    // scan in move direction until an empty cell or a "hole" is reached
    NSInteger curRow = startRow + rowDelta;
    NSInteger curColumn = startColumn + columnDelta;
    JCSFlipCellState curState;
    while ((curState = [self cellStateAtRow:curRow column:curColumn]) != JCSFlipCellStateHole && curState != JCSFlipCellStateEmpty) {
        curRow += rowDelta;
        curColumn += columnDelta;
    }
    
    // fail if no empty cell is reached
    if (curState != JCSFlipCellStateEmpty) {
        return NO;
    }

    // iterate again to flip cells
    curRow = startRow + rowDelta;
    curColumn = startColumn + columnDelta;
    while ((curState = [self cellStateAtRow:curRow column:curColumn]) != JCSFlipCellStateHole && curState != JCSFlipCellStateEmpty) {
        [self setCellState:JCSFlipCellStateOther(curState) atRow:curRow column:curColumn];
        curRow += rowDelta;
        curColumn += columnDelta;
    }

    // occupy empty target cell
    [self setCellState:startCellState atRow:curRow column:curColumn];
    
    // switch players
    _playerToMove = JCSFlipPlayerOther(_playerToMove);
    
    // move successful
    return YES;
}

- (void)forAllNextStatesInvokeBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block {
    NSAssert(block != nil, @"block must not be nil");
    
    JCSFlipCellState playerCellState = JCSFlipCellStateForPlayer(_playerToMove);
    
    [self forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        // try cells with the correct owner as starting cells 
        if (cellState == playerCellState) {
            // try all directions, but stop if the block says to do so
            for (JCSHexDirection direction = JCSHexDirectionMin; direction <= JCSHexDirectionMax && !*stop; direction++) {
                JCSFlipMove *move = [JCSFlipMove moveWithStartRow:row startColumn:column direction:direction];
                JCSFlipGameState *stateCopy = [self copy];
                if ([stateCopy applyMove:move]) {
                    // move is valid - invoke block
                    block(move, stateCopy, stop);
                }
            }
        }
    }];
}

#pragma mark NSCopying methods

- (id)copyWithZone:(NSZone *)zone {
	// create a new instance, using the current values
	return [[[self class] allocWithZone:zone] initWithSize:_size playerToMove:_playerToMove cellStateAtBlock:^JCSFlipCellState(NSInteger row, NSInteger column) {
        return [self cellStateAtRow:row column:column];
    }];
}

// return the string representation of the board
- (NSString *)description {
    NSMutableString *temp = [NSMutableString string];
    for (int row = _size-1; row > -_size; row--) {
        for (NSInteger i = 0; i < _size-1+row; i++) {
            [temp appendString:@" "];
        }
        for (NSInteger col = -_size+1; col < _size; col++) {
            NSString *cellString;
            JCSFlipCellState cellState = [self cellStateAtRow:row column:col];
            if (cellState == JCSFlipCellStateOwnedByPlayerA) {
                cellString = @"A";
            } else if (cellState == JCSFlipCellStateOwnedByPlayerB) {
                cellString = @"B";
            } else if (cellState == JCSFlipCellStateEmpty) {
                cellString = @".";
            } else {
                cellString = @" ";
            }
            [temp appendString:cellString];
            if (col < _size-1) {
                [temp appendString:@" "];
            }
        }
        [temp appendString:@"\n"];
    }
    return [NSString stringWithString:temp];
}

@end
