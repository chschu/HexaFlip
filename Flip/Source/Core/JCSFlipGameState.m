//
//  JCSFlipGameState.m
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipCellState.h"
#import "JCSFlipMutableMove.h"

// enumeration for the "skip allowed" flag
typedef enum {
    JCSFlipGameStateSkipAllowedUnknown = -1,
    JCSFlipGameStateSkipAllowedNo = 0,
    JCSFlipGameStateSkipAllowedYes = 1,
} JCSFlipGameStateSkipAllowed;

// simple container structure holding move information
// this struct contains a "next" pointer to represent a stack
typedef struct JCSFlipGameStateMoveInfo {
    // skip flag of the move
    BOOL skip;
    
    // start row of the move
    NSInteger startRow;
    
    // start column of the move
    NSInteger startColumn;
    
    // direction of the move
    JCSHexDirection direction;
    
    // number of cells flipped by the move
    NSInteger flipCount;
    
    // value of the "skip allowed" flag before the move had been applied
    JCSFlipGameStateSkipAllowed oldSkipAllowed;
    
    // stack element below this one, or NULL if there are none
    struct JCSFlipGameStateMoveInfo *next;
} JCSFlipGameStateMoveInfo;

@implementation JCSFlipGameState {
    // size of the grid
    // coordinates are between -(size-1) and (size-1), both inclusive
    NSInteger _size;
    
    // cell states for all cells in the grid, in row-major order
    // the state of the cell at (r,c) is stored at index (2*size-1)*(r+(size-1)) + c+(size-1)
    JCSFlipCellState *_cellStates;
    
    // is the "skip" move allowed?
    JCSFlipGameStateSkipAllowed _skipAllowed;
    
    // top element of the stack of moves pushed by -pushMove:
    // NULL if the stack is empty
    JCSFlipGameStateMoveInfo *_moveInfoStackTop;
}

@synthesize cellCountPlayerA = _cellCountPlayerA;
@synthesize cellCountPlayerB = _cellCountPlayerB;
@synthesize cellCountEmpty = _cellCountEmpty;
@synthesize playerToMove = _playerToMove;

#pragma mark instance methods

// index into the cell states array
// parameters: row in [-(size-1),(size-1)], column in [-(size-1),(size-1)]
#define JCS_CELL_STATE_INDEX(row, column) ((2*_size-1)*((row)+(_size-1)) + (column)+(_size-1))

// designated initializer
- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayerToMove)playerToMove cellStateAtBlock:(JCSFlipCellState(^)(NSInteger row, NSInteger column))cellStateAtBlock {
	NSAssert(size >= 0, @"size must be non-negative");
	NSAssert(cellStateAtBlock != nil, @"cellStateAt block must not be nil");
    
    if (self = [super init]) {
        _size = size;
        _playerToMove = playerToMove;
        _cellStates = malloc((2*_size-1)*(2*_size-1)*sizeof(JCSFlipCellState));
        _skipAllowed = JCSFlipGameStateSkipAllowedUnknown;
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
        
        // initialize the move stack (empty)
        _moveInfoStackTop = NULL;
    }
    
	return self;
}

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) (MAX(MAX(abs((r1)-(r2)), abs((c1)-(c2))), abs((0-(r1)-(c1))-(0-(r2)-(c2)))))

- (id)initDefaultWithSize:(NSInteger)size {
    return [self initWithSize:size playerToMove:JCSFlipPlayerToMoveA cellStateAtBlock:^JCSFlipCellState(NSInteger row, NSInteger column) {
        NSInteger distanceFromOrigin = JCS_HEX_DISTANCE(row, column, 0, 0);
        if (distanceFromOrigin == 0 || distanceFromOrigin > size-1) {
            return JCSFlipCellStateHole;
        } else if (distanceFromOrigin == 1) {
            if (row + 2*column < 0) {
                return JCSFlipCellStateOwnedByPlayerA;
            } else {
                return JCSFlipCellStateOwnedByPlayerB;
            }
        } else {
            return JCSFlipCellStateEmpty;
        }
    }];
}

- (void)dealloc {
    // free the move stack
    while (_moveInfoStackTop != NULL) {
        JCSFlipGameStateMoveInfo *oldTop = _moveInfoStackTop;
        _moveInfoStackTop = _moveInfoStackTop->next;
        free(oldTop);
    }
    
    // free the cell states array
    free(_cellStates);
}

// getter for the current game status
- (JCSFlipGameStatus)status {
    JCSFlipGameStatus status;
	if (_cellCountPlayerA == 0 || _cellCountPlayerB == 0 || _cellCountEmpty == 0) {
		if (_cellCountPlayerA > _cellCountPlayerB) {
			status = JCSFlipGameStatusPlayerAWon;
		} else if (_cellCountPlayerB > _cellCountPlayerA) {
			status = JCSFlipGameStatusPlayerBWon;
		} else {
			status = JCSFlipGameStatusDraw;
		}
	} else {
        status = JCSFlipGameStatusOpen;
    }
    return status;
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
    if (_skipAllowed == JCSFlipGameStateSkipAllowedUnknown) {
        // this initializes the "skip allowed" flag properly
        [self applyAllPossibleMovesAndInvokeBlock:^(JCSFlipMove *move, BOOL *stop) {
            // stop at the first move
            *stop = YES;
        }];
    }
    return _skipAllowed == JCSFlipGameStateSkipAllowedYes;
}

- (BOOL)pushMove:(JCSFlipMove *)move {
    NSAssert(move != nil, @"move must not be nil");
    
    // fail if the game is over
    if (JCSFlipGameStatusIsOver(self.status)) {
        return NO;
    }
    
    NSInteger flipCount = 0;
    
    if (!move.skip) {
        NSInteger startRow = move.startRow;
        NSInteger startColumn = move.startColumn;
        
        JCSFlipCellState startCellState = [self cellStateAtRow:startRow column:startColumn];
        
        // cell state of start cell must match player
        if (startCellState != JCSFlipCellStateForPlayerToMove(_playerToMove)) {
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
            flipCount++;
        }
        
        // occupy empty target cell
        [self setCellState:startCellState atRow:curRow column:curColumn];
    } else if (![self skipAllowed]) {
        // skip is not allowed
        return NO;
    }
    
    // populate move info
    JCSFlipGameStateMoveInfo *moveInfo = malloc(sizeof(JCSFlipGameStateMoveInfo));
    moveInfo->skip = move.skip;
    if (!moveInfo->skip) {
        moveInfo->startRow = move.startRow;
        moveInfo->startColumn = move.startColumn;
        moveInfo->direction = move.direction;
    }
    moveInfo->flipCount = flipCount;
    moveInfo->oldSkipAllowed = _skipAllowed;
    
    // push move info on the stack
    moveInfo->next = _moveInfoStackTop;
    _moveInfoStackTop = moveInfo;
    
    // switch players
    _playerToMove = JCSFlipPlayerToMoveOther(_playerToMove);
    
    // "skip allowed" flag needs to be determined
    _skipAllowed = JCSFlipGameStateSkipAllowedUnknown;
    
    // move successful
    return YES;
}

- (void)popMove {
    // pop the move info from the stack
    NSAssert(_moveInfoStackTop != NULL, @"move stack is empty");
    JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStackTop;
    _moveInfoStackTop = _moveInfoStackTop->next;
    
    if (!moveInfo->skip) {
        NSInteger flipCount = moveInfo->flipCount;
        
        JCSHexDirection direction = moveInfo->direction;
        NSInteger rowDelta = JCSHexDirectionRowDelta(direction);
        NSInteger columnDelta = JCSHexDirectionColumnDelta(direction);
        
        // iterate to flip back cells
        NSInteger curRow = moveInfo->startRow + rowDelta;
        NSInteger curColumn = moveInfo->startColumn + columnDelta;
        for (NSInteger i = flipCount; i > 0; i--) {
            JCSFlipCellState curState = [self cellStateAtRow:curRow column:curColumn];
            [self setCellState:JCSFlipCellStateOther(curState) atRow:curRow column:curColumn];
            curRow += rowDelta;
            curColumn += columnDelta;
        }
        
        // free target cell
        [self setCellState:JCSFlipCellStateEmpty atRow:curRow column:curColumn];
    }
    
    // put back old values
    _skipAllowed = moveInfo->oldSkipAllowed;
    
    // switch back players
    _playerToMove = JCSFlipPlayerToMoveOther(_playerToMove);
    
    // release the move info
    free(moveInfo);
}

- (void)forAllCellsInvolvedInLastMoveInvokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop))block {
    // peek at the move info from the stack
    NSAssert(_moveInfoStackTop != NULL, @"move stack is empty");
    JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStackTop;
    
    if (!moveInfo->skip) {
        NSInteger flipCount = moveInfo->flipCount;
        
        JCSHexDirection direction = moveInfo->direction;
        NSInteger rowDelta = JCSHexDirectionRowDelta(direction);
        NSInteger columnDelta = JCSHexDirectionColumnDelta(direction);
        
        BOOL stop = NO;
        
        // invoke block for start cell, flipped cells, and target cell (total: modCount+1 cells)
        NSInteger curRow = moveInfo->startRow;
        NSInteger curColumn = moveInfo->startColumn;
        for (NSInteger i = flipCount + 1; i >= 0 && !stop; i--) {
            JCSFlipCellState newCellState = [self cellStateAtRow:curRow column:curColumn];
            JCSFlipCellState oldCellState;
            if (i == flipCount + 1) {
                // start cell
                oldCellState = newCellState;
            } else if (i == 0) {
                // target cell
                oldCellState = JCSFlipCellStateEmpty;
            } else {
                // flipped cell
                oldCellState = JCSFlipCellStateOther(newCellState);
            }
            block(curRow, curColumn, oldCellState, newCellState, &stop);
            curRow += rowDelta;
            curColumn += columnDelta;
        }
    }
}

- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(JCSFlipMove *move, BOOL *stop))block {
    NSAssert(block != nil, @"block must not be nil");
    
    if (JCSFlipGameStatusIsOver(self.status)) {
        // skipping is not allowed
        _skipAllowed = JCSFlipGameStateSkipAllowedNo;

        // no need to try any moves
        return;
    }
    
    JCSFlipCellState playerCellState = JCSFlipCellStateForPlayerToMove(_playerToMove);
    
    __block BOOL hasValidMove = NO;
    
    // initialize dummy move
    JCSFlipMutableMove *move = [JCSFlipMutableMove moveWithStartRow:0 startColumn:0 direction:JCSHexDirectionE];
    
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
                if ([self pushMove:move]) {
                    // move is valid - invoke block with immutable move copy
                    JCSFlipMove *moveCopy = [move copy];
                    block(moveCopy, stop);
                    
                    // undo the move
                    [self popMove];
                    
                    // we have a move
                    hasValidMove = YES;
                }
            }
        }
    }];
    
    if (!hasValidMove) {
        // skipping is allowed
        _skipAllowed = JCSFlipGameStateSkipAllowedYes;
        
        // update move date
        move.skip = YES;
        
        // apply skip move
        if ([self pushMove:move]) {
            // move is valid - invoke block with immutable move copy and dummy stop flag
            JCSFlipMove *moveCopy = [move copy];
            BOOL stop = NO;
            block(moveCopy, &stop);
            
            // undo the move
            [self popMove];
        } else {
            NSAssert(NO, @"skip move is valid, but can not be applied");
        }
    } else {
        // skipping is not allowed
        _skipAllowed = JCSFlipGameStateSkipAllowedNo;
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

- (JCSFlipMove *)lastMove {
    if (_moveInfoStackTop == NULL) {
        return nil;
    }
    if (_moveInfoStackTop->skip == YES) {
        return [JCSFlipMove moveSkip];
    }
    return [JCSFlipMove moveWithStartRow:_moveInfoStackTop->startRow startColumn:_moveInfoStackTop->startColumn direction:_moveInfoStackTop->direction];
}

#pragma mark NSCoding (serialization/deserialization)

NSString *coderKey_size = @"a";
NSString *coderKey_playerToMove = @"b";
NSString *coderKey_cellStates = @"c";
NSString *coderKey_moveStackArray = @"d";

// converts the move stack to an array, converting no more than the given number of moves
// stack top comes first in array
- (NSArray *)convertMoveStackToArray:(JCSFlipGameStateMoveInfo *)moveInfoStackTop maxMoves:(NSUInteger)maxMoves {
    NSMutableArray *array = [NSMutableArray array];
    
    JCSFlipGameStateMoveInfo *curEntry = moveInfoStackTop;
    NSUInteger i = 0;
    while (i < maxMoves && curEntry != NULL) {
        [array addObject:[NSNumber numberWithBool:curEntry->skip]];
        [array addObject:[NSNumber numberWithInteger:curEntry->startRow]];
        [array addObject:[NSNumber numberWithInteger:curEntry->startColumn]];
        [array addObject:[NSNumber numberWithInt:curEntry->direction]];
        [array addObject:[NSNumber numberWithInteger:curEntry->flipCount]];
        [array addObject:[NSNumber numberWithInt:curEntry->oldSkipAllowed]];
        
        curEntry = curEntry->next;
        i++;
    }
    
    // return immutable copy
    return [array copy];
}

// converts the array to a move stack, starting at the specified index
// stack top comes first in array
- (JCSFlipGameStateMoveInfo *)convertArrayToMoveStack:(NSArray *)array startIndex:(NSUInteger)startIndex {
    if (startIndex >= array.count) {
        return NULL;
    }
    
    JCSFlipGameStateMoveInfo *curEntry = malloc(sizeof(JCSFlipGameStateMoveInfo));
    NSUInteger index = startIndex;
    curEntry->skip = [[array objectAtIndex:index++] boolValue];
    curEntry->startRow = [[array objectAtIndex:index++] integerValue];
    curEntry->startColumn = [[array objectAtIndex:index++] integerValue];
    curEntry->direction = [[array objectAtIndex:index++] intValue];
    curEntry->flipCount = [[array objectAtIndex:index++] integerValue];
    curEntry->oldSkipAllowed = [[array objectAtIndex:index++] intValue];
    curEntry->next = [self convertArrayToMoveStack:array startIndex:index++];
    
    return curEntry;
}

- (void)encodeWithCoder:(NSCoder *)aCoder maxMoves:(NSUInteger)maxMoves {
    [aCoder encodeInteger:_size forKey:coderKey_size];
    [aCoder encodeInt:_playerToMove forKey:coderKey_playerToMove];
    [aCoder encodeBytes:_cellStates length:(2*_size-1)*(2*_size-1) forKey:coderKey_cellStates];
    [aCoder encodeObject:[self convertMoveStackToArray:_moveInfoStackTop maxMoves:maxMoves] forKey:coderKey_moveStackArray];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // encode the full move stack
    [self encodeWithCoder:aCoder maxMoves:NSUIntegerMax];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger size = [aDecoder decodeIntegerForKey:coderKey_size];
    JCSFlipPlayerToMove playerToMove = [aDecoder decodeIntForKey:coderKey_playerToMove];
    
    NSUInteger length;
    const JCSFlipCellState *cellStates = [aDecoder decodeBytesForKey:coderKey_cellStates returnedLength:&length];
    NSAssert(length == (2*size-1)*(2*size-1), @"invalid length");
    
    self = [self initWithSize:size playerToMove:playerToMove cellStateAtBlock:^JCSFlipCellState(NSInteger row, NSInteger column) {
        return cellStates[JCS_CELL_STATE_INDEX(row, column)];
    }];
    
    _moveInfoStackTop = [self convertArrayToMoveStack:[aDecoder decodeObjectForKey:coderKey_moveStackArray] startIndex:0];
    
    return self;
}

@end
