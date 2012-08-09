//
//  JCSFlipGameState.m
//  Flip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipCellState.h"
#import "JCSFlipMutableMove.h"

// simple container class for move information
@interface JCSFlipGameStateMoveInfo : NSObject {
    @package
    // number of cells modified by the move (x flipped + 1 occupied)
    NSInteger modCount;
    
    // status before the move had been applied
    JCSFlipGameStatus oldStatus;
    
    // value of the "skip allowed" container before the move had been applied
    NSNumber *oldSkipAllowed;
}
@end

@implementation JCSFlipGameStateMoveInfo
@end

@implementation JCSFlipGameState {
    // size of the grid
    // coordinates are between -(size-1) and (size-1), both inclusive
    NSInteger _size;
    
    // cell states for all cells in the grid, in row-major order
    // the state of the cell at (r,c) is stored at index (2*size-1)*(r+(size-1)) + c+(size-1)
    JCSFlipCellState *_cellStates;

    // container holding YES if skipping is allowed, NO if it is not
    // if this is nil, it is unknown if skipping is allowed
    // this is immutable, and may be reused in different game state instances
    NSNumber *_skipAllowed;
}

@synthesize status = _status;
@synthesize cellCountPlayerA = _cellCountPlayerA;
@synthesize cellCountPlayerB = _cellCountPlayerB;
@synthesize cellCountEmpty = _cellCountEmpty;

#pragma mark instance methods

// index into the cell states array
// parameters: row in [-(size-1),(size-1)], column in [-(size-1),(size-1)]
#define JCS_CELL_STATE_INDEX(row, column) ((2*_size-1)*((row)+(_size-1)) + (column)+(_size-1))

// designated initializer
- (id)initWithSize:(NSInteger)size status:(JCSFlipGameStatus)status cellStateAtBlock:(JCSFlipCellState(^)(NSInteger row, NSInteger column))cellStateAtBlock {
	NSAssert(size >= 0, @"size must be non-negative");
	NSAssert(cellStateAtBlock != nil, @"cellStateAt block must not be nil");
    
    if (self = [super init]) {
        _size = size;
        _status = status;
        _cellStates = malloc((2*_size-1)*(2*_size-1)*sizeof(JCSFlipCellState));
        _skipAllowed = nil;
        _cellCountPlayerA = 0;
        _cellCountPlayerB = 0;
        _cellCountEmpty = 0;
        NSInteger index = 0;
        for (NSInteger row = -size+1; row < size; row++) {
            for (NSInteger column = -size+1; column < size; column++) {
                _cellStates[index] = cellStateAtBlock(row, column);
                // count initial cell states
                switch (_cellStates[index]) {
                    case JCSFlipCellStateOwnedByPlayerA:
                        _cellCountPlayerA++;
                        break;
                    case JCSFlipCellStateOwnedByPlayerB:
                        _cellCountPlayerB++;
                        break;
                    case JCSFlipCellStateEmpty:
                        _cellCountEmpty++;
                        break;
                    default:
                        break;
                }
                index++;
            }
        }

        // check game over and update state (quite strange at this stage, but possible)
        [self updateStateIfGameOver];
    }
    
	return self;
}

- (void)dealloc {
    free(_cellStates);
}

// check if game is over and set state accordingly
- (void)updateStateIfGameOver {
	if (_cellCountPlayerA == 0 || _cellCountPlayerB == 0 || _cellCountEmpty == 0) {
		if (_cellCountPlayerA > _cellCountPlayerB) {
			_status = JCSFlipGameStatusPlayerAWon;
		} else if (_cellCountPlayerB > _cellCountPlayerA) {
			_status = JCSFlipGameStatusPlayerBWon;
		} else {
			_status = JCSFlipGameStatusDraw;
		}
	}
}

- (void)forAllCellsInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop))block {
    BOOL stop = NO;
    NSInteger index = 0;
    for (NSInteger row = -_size+1; row < _size && !stop; row++) {
        for (NSInteger column = -_size+1; column < _size && !stop; column++) {
            block(row, column, _cellStates[index], &stop);
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

    // subtract one for old state
    switch (_cellStates[index]) {
        case  JCSFlipCellStateOwnedByPlayerA:
            _cellCountPlayerA--;
            break;
        case  JCSFlipCellStateOwnedByPlayerB:
            _cellCountPlayerB--;
            break;
        case  JCSFlipCellStateEmpty:
            _cellCountEmpty--;
            break;
        default:
            break;
    }
    
    _cellStates[index] = cellState;

    // add one for new state
    switch (_cellStates[index]) {
        case  JCSFlipCellStateOwnedByPlayerA:
            _cellCountPlayerA++;
            break;
        case  JCSFlipCellStateOwnedByPlayerB:
            _cellCountPlayerB++;
            break;
        case  JCSFlipCellStateEmpty:
            _cellCountEmpty++;
            break;
        default:
            break;
    }
}

// determine if skipping is allowed
- (BOOL)skipAllowed {
    if (_skipAllowed == nil) {
        // this initializes the "skip allowed" flag properly
        [self applyAllPossibleMovesAndInvokeBlock:^(JCSFlipMove *move, BOOL *stop) {
            // stop at the first move
            *stop = YES;
        }];
    }
    return [_skipAllowed boolValue];
}

- (BOOL)applyMove:(JCSFlipMove *)move {
    return [self applyMove:move moveInfo:nil];
}

- (id)newMoveInfo {
    return [[JCSFlipGameStateMoveInfo alloc] init];
}

- (BOOL)applyMove:(JCSFlipMove *)move moveInfo:(id)moveInfo {
    NSAssert(move != nil, @"move must not be nil");
    NSAssert(moveInfo == nil || [moveInfo class] == [JCSFlipGameStateMoveInfo class], @"invalid moveInfo object");

    // fail if the game is over
    if (!(_status == JCSFlipGameStatusPlayerAToMove || _status == JCSFlipGameStatusPlayerBToMove)) {
        return NO;
    }
    
    NSInteger modCount = 0;
    
    if (!move.skip) {
        NSInteger startRow = move.startRow;
        NSInteger startColumn = move.startColumn;
        
        JCSFlipCellState startCellState = [self cellStateAtRow:startRow column:startColumn];

        // cell state of start cell must match player
        if (startCellState != JCSFlipCellStateForGameStatus(_status)) {
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
        while ((curState = [self cellStateAtRow:curRow column:curColumn]) != JCSFlipCellStateEmpty) {
            [self setCellState:JCSFlipCellStateOther(curState) atRow:curRow column:curColumn];
            curRow += rowDelta;
            curColumn += columnDelta;
            modCount++;
        }
        
        // occupy empty target cell
        [self setCellState:startCellState atRow:curRow column:curColumn];
        modCount++;
    } else if (![self skipAllowed]) {
        // skip is not allowed
        return NO;
    }
    
    // populate move info
    if (moveInfo != nil) {
        ((JCSFlipGameStateMoveInfo *) moveInfo)->modCount = modCount;
        ((JCSFlipGameStateMoveInfo *) moveInfo)->oldStatus = _status;
        ((JCSFlipGameStateMoveInfo *) moveInfo)->oldSkipAllowed = _skipAllowed;
    }
    
    // switch players
    _status = JCSFlipGameStatusOtherPlayerToMove(_status);
    
    // update the state if the game is over
    [self updateStateIfGameOver];
    
    // "skip allowed" flag needs to be determined
    _skipAllowed = nil;
    
    // move successful
    return YES;
}

- (void)unapplyMove:(JCSFlipMove *)move moveInfo:(id)moveInfo {
    NSAssert(move != nil, @"move must not be nil");
    NSAssert([moveInfo class] == [JCSFlipGameStateMoveInfo class], @"invalid moveInfo object");
    
    NSInteger modCount = ((JCSFlipGameStateMoveInfo *) moveInfo)->modCount;

    if (modCount > 0) {
        JCSHexDirection direction = move.direction;
        NSInteger rowDelta = JCSHexDirectionRowDelta(direction);
        NSInteger columnDelta = JCSHexDirectionColumnDelta(direction);

        // iterate to flip back cells
        NSInteger curRow = move.startRow + rowDelta;
        NSInteger curColumn = move.startColumn + columnDelta;
        for (NSInteger i = modCount-1; i > 0; i--) {
            JCSFlipCellState curState = [self cellStateAtRow:curRow column:curColumn];
            [self setCellState:JCSFlipCellStateOther(curState) atRow:curRow column:curColumn];
            curRow += rowDelta;
            curColumn += columnDelta;
        }
        
        // free target cell
        [self setCellState:JCSFlipCellStateEmpty atRow:curRow column:curColumn];
    }
    
    // put back old values
    _status = ((JCSFlipGameStateMoveInfo *) moveInfo)->oldStatus;
    _skipAllowed = ((JCSFlipGameStateMoveInfo *) moveInfo)->oldSkipAllowed;
}

- (void)forAllCellsChangedByMove:(JCSFlipMove *)move moveInfo:(id)moveInfo invokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState newCellState, BOOL *stop))block {
    NSAssert(move != nil, @"move must not be nil");
    NSAssert([moveInfo class] == [JCSFlipGameStateMoveInfo class], @"invalid moveInfo object");
    
    
    NSInteger modCount = ((JCSFlipGameStateMoveInfo *) moveInfo)->modCount;
    
    if (modCount > 0) {
        JCSHexDirection direction = move.direction;
        NSInteger rowDelta = JCSHexDirectionRowDelta(direction);
        NSInteger columnDelta = JCSHexDirectionColumnDelta(direction);
        
        BOOL stop = NO;
        
        // invoke block for flipped cells
        NSInteger curRow = move.startRow + rowDelta;
        NSInteger curColumn = move.startColumn + columnDelta;
        for (NSInteger i = modCount-1; i > 0 && !stop; i--) {
            block(curRow, curColumn, [self cellStateAtRow:curRow column:curColumn], &stop);
            curRow += rowDelta;
            curColumn += columnDelta;
        }
        
        // invoke block for target cell
        if (!stop) {
            block(curRow, curColumn, [self cellStateAtRow:curRow column:curColumn], &stop);
        }
    }
}

- (BOOL)resign {
	if (_status == JCSFlipGameStatusPlayerAToMove) {
		_status = JCSFlipGameStatusPlayerBWon;
		return YES;
    } else if (_status == JCSFlipGameStatusPlayerBToMove) {
        _status = JCSFlipGameStatusPlayerAWon;
        return YES;
    } else {
        return NO;
    }
}

- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(JCSFlipMove *move, BOOL *stop))block {
    NSAssert(block != nil, @"block must not be nil");

    // don't do anything if the game is over
    if (!(_status == JCSFlipGameStatusPlayerAToMove || _status == JCSFlipGameStatusPlayerBToMove)) {
        return;
    }
    
    JCSFlipCellState playerCellState = JCSFlipCellStateForGameStatus(_status);
    
    __block BOOL hasValidMove = NO;
    
    // initialize dummy move;
    __block JCSFlipMutableMove *move = [JCSFlipMutableMove moveWithStartRow:0 startColumn:0 direction:JCSHexDirectionE];
    
    // allocate a single move info instace
    id moveInfo = [self newMoveInfo];
    
    [self forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        // try cells with the correct owner as starting cells
        if (cellState == playerCellState) {
            // update move data
            move.startRow = row;
            move.startColumn = column;

            // try all directions, but stop if the block says to do so
            for (JCSHexDirection direction = JCSHexDirectionMin; direction <= JCSHexDirectionMax && !*stop; direction++) {
                move.direction = direction;
                // try the move
                if ([self applyMove:move moveInfo:moveInfo]) {
                    // move is valid - invoke block with immutable move copy
                    JCSFlipMove *moveCopy = [move copy];
                    block(moveCopy, stop);
                    
                    // undo the move
                    [self unapplyMove:move moveInfo:moveInfo];
                    
                    // we have a move
                    hasValidMove = YES;
                }
            }
        }
    }];
    
    if (!hasValidMove) {
        // skipping is allowed
        _skipAllowed = [NSNumber numberWithBool:YES];
        
        // update move date
        move.skip = YES;
        
        // apply skip move
        if ([self applyMove:move moveInfo:moveInfo]) {
            // move is valid - invoke block with immutable move copy and dummy stop flag
            JCSFlipMove *moveCopy = [move copy];
            BOOL stop = NO;
            block(moveCopy, &stop);

            // undo the move
            [self unapplyMove:move moveInfo:moveInfo];
        } else {
            NSAssert(NO, @"skip move is valid, but can not be applied");
        }
    } else {
        // skipping is not allowed
        _skipAllowed = [NSNumber numberWithBool:NO];
    }
}

#pragma mark Debugging helper methods

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
