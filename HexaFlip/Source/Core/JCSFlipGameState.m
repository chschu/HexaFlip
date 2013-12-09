//
//  JCSFlipGameState.m
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState.h"
#import "JCSFlipCellState.h"
#import "JCSFlipMove.h"

// enumeration for the "skip allowed" flag
enum {
    JCSFlipGameStateSkipAllowedUnknown = -1,
    JCSFlipGameStateSkipAllowedNo = 0,
    JCSFlipGameStateSkipAllowedYes = 1,
};

typedef int JCSFlipGameStateSkipAllowed;

// simple container structure holding move information
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
    
    // base pointer of the move stack used by -pushMove:
    JCSFlipGameStateMoveInfo *_moveInfoStack;
    
    // index of the element behind the last pushed
    NSUInteger _moveInfoStackTop;
    
    // number of entries allocated for the stack (increased on demand)
    NSUInteger _moveInfoStackCapacity;
    
    // the parts of the Zobrist hash for cells owned by player A
    NSUInteger *_zobristHashPartA;

    // the parts of the Zobrist hash for cells owned by player B
    NSUInteger *_zobristHashPartB;

    // the parts of the Zobrist hash for empty cells
    NSUInteger *_zobristHashPartEmpty;

    // the parts of the Zobrist hash for hole cells
    NSUInteger *_zobristHashPartHole;

    // the part of the Zobrist hash indicating that it's player A's turn
    NSUInteger _zobristHashPartPlayerAToMove;

    // the part of the Zobrist hash indicating that it's player B's turn
    NSUInteger _zobristHashPartPlayerBToMove;
    
    // the current Zobrist hash (updated whenever the state changes)
    NSUInteger _zobristHash;
}

@synthesize cellCountPlayerA = _cellCountPlayerA;
@synthesize cellCountPlayerB = _cellCountPlayerB;
@synthesize cellCountEmpty = _cellCountEmpty;
@synthesize playerToMove = _playerToMove;
@synthesize moveStackSize = _moveInfoStackTop;
@synthesize zobristHash = _zobristHash;

#pragma mark instance methods

// index into the cell states array
// parameters: row in [-(size-1),(size-1)], column in [-(size-1),(size-1)]
#define JCS_CELL_STATE_INDEX(size, row, column) ({ \
__typeof__(size) _s = (size); \
__typeof__(row) _r = (row); \
__typeof__(column) _c = (column); \
(2*_s-1)*(_r+(_s-1)) + (_c+(_s-1)); \
})

// total number of cells (including holes)
#define JCS_CELL_COUNT(size) ({ \
__typeof__(size) _s = (size); \
(2*_s-1)*(2*_s-1); \
})

// designated initializer
- (id)initWithSize:(NSInteger)size playerToMove:(JCSFlipPlayerSide)playerToMove cellStateAtBlock:(JCSFlipCellState(^)(NSInteger row, NSInteger column))cellStateAtBlock {
	NSAssert(size >= 0, @"size must be non-negative");
	NSAssert(cellStateAtBlock != nil, @"cellStateAt block must not be nil");
    
    if (self = [super init]) {
        _size = size;
        NSUInteger cellCount = JCS_CELL_COUNT(_size);
        _playerToMove = playerToMove;
        _cellStates = malloc(cellCount*sizeof(JCSFlipCellState));
        _zobristHashPartA = malloc(cellCount*sizeof(NSUInteger));
        _zobristHashPartB = malloc(cellCount*sizeof(NSUInteger));
        _zobristHashPartEmpty = malloc(cellCount*sizeof(NSUInteger));
        _zobristHashPartHole = malloc(cellCount*sizeof(NSUInteger));
        _skipAllowed = JCSFlipGameStateSkipAllowedUnknown;
        _cellCountPlayerA = 0;
        _cellCountPlayerB = 0;
        _cellCountEmpty = 0;
        _zobristHash = 0;

        // compute pseudo-random Zobrist hash parts (using 31-bit pseudo-random numbers is sufficient)
        // this sequence must be deterministic, in order to reliably map equivalent states to the same Zobrist hash
        NSUInteger seed = 1;
        
        // initialize cell states, XOR into Zobrist hash
        NSInteger index = 0;
        for (NSInteger row = -size+1; row < size; row++) {
            for (NSInteger column = -size+1; column < size; column++) {
                _zobristHashPartA[index] = rand_r(&seed);
                _zobristHashPartB[index] = rand_r(&seed);
                _zobristHashPartEmpty[index] = rand_r(&seed);
                _zobristHashPartHole[index] = rand_r(&seed);
                _cellStates[index] = cellStateAtBlock(row, column);
                // count initial cell states
                switch (_cellStates[index]) {
                    case JCSFlipCellStateOwnedByPlayerA:
                        _cellCountPlayerA++;
                        _zobristHash ^= _zobristHashPartA[index];
                        break;
                    case JCSFlipCellStateOwnedByPlayerB:
                        _cellCountPlayerB++;
                        _zobristHash ^= _zobristHashPartB[index];
                        break;
                    case JCSFlipCellStateEmpty:
                        _cellCountEmpty++;
                        _zobristHash ^= _zobristHashPartEmpty[index];
                        break;
                    default:
                        _zobristHash ^= _zobristHashPartHole[index];
                        break;
                }
                index++;
            }
        }
        
        // XOR player into Zobrist hash
        _zobristHashPartPlayerAToMove = rand_r(&seed);
        _zobristHashPartPlayerBToMove = rand_r(&seed);
        _zobristHash ^= (_playerToMove == JCSFlipPlayerSideA ? _zobristHashPartPlayerAToMove : _zobristHashPartPlayerBToMove);
        
        // initialize the move stack (empty)
        _moveInfoStackCapacity = 8;
        _moveInfoStackTop = 0;
        _moveInfoStack = malloc(_moveInfoStackCapacity*sizeof(JCSFlipGameStateMoveInfo));
    }
    
	return self;
}

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) ({ \
__typeof__(r1) _r1 = (r1); \
__typeof__(c1) _c1 = (c1); \
__typeof__(r2) _r2 = (r2); \
__typeof__(c2) _c2 = (c2); \
MAX(MAX(abs(_r1-_r2), abs(_c1-_c2)), abs((_r1+_c1)-(_r2+_c2))); \
})

- (id)initDefaultWithSize:(NSInteger)size playerToMove:(JCSFlipPlayerSide)playerToMove {
    return [self initWithSize:size playerToMove:playerToMove cellStateAtBlock:^JCSFlipCellState(NSInteger row, NSInteger column) {
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
    free(_moveInfoStack);
    
    // free the cell states array
    free(_cellStates);
    
    // free the Zobrist hash part arrays
    free(_zobristHashPartA);
    free(_zobristHashPartB);
    free(_zobristHashPartEmpty);
    free(_zobristHashPartHole);
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
    NSInteger index = JCS_CELL_STATE_INDEX(_size, row, column);
    return _cellStates[index];
}

// private accessor to set a cell state (without range check)
- (void)setCellState:(JCSFlipCellState)cellState atRow:(NSInteger)row column:(NSInteger)column {
    NSInteger index = JCS_CELL_STATE_INDEX(_size, row, column);
    
    // subtract one for old state, XOR out of Zobrist hash
    switch (_cellStates[index]) {
        case  JCSFlipCellStateOwnedByPlayerA:
            _cellCountPlayerA--;
            _zobristHash ^= _zobristHashPartA[index];
            break;
        case  JCSFlipCellStateOwnedByPlayerB:
            _cellCountPlayerB--;
            _zobristHash ^= _zobristHashPartB[index];
            break;
        case  JCSFlipCellStateEmpty:
            _cellCountEmpty--;
            _zobristHash ^= _zobristHashPartEmpty[index];
            break;
        default:
            _zobristHash ^= _zobristHashPartHole[index];
            break;
    }
    
    _cellStates[index] = cellState;
    
    // add one for new state, XOR into Zobrist hash
    switch (_cellStates[index]) {
        case  JCSFlipCellStateOwnedByPlayerA:
            _cellCountPlayerA++;
            _zobristHash ^= _zobristHashPartA[index];
            break;
        case  JCSFlipCellStateOwnedByPlayerB:
            _cellCountPlayerB++;
            _zobristHash ^= _zobristHashPartB[index];
            break;
        case  JCSFlipCellStateEmpty:
            _cellCountEmpty++;
            _zobristHash ^= _zobristHashPartEmpty[index];
            break;
        default:
            _zobristHash ^= _zobristHashPartHole[index];
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

- (void)forAllCellsInvolvedInLastMoveReverse:(BOOL)reverse invokeBlock:(void(^)(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop))block {
    // peek at the move info from the stack
    NSAssert(_moveInfoStackTop != 0, @"move stack is empty");
    JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStack + _moveInfoStackTop-1;
    
    if (!moveInfo->skip) {
        NSInteger flipCount = moveInfo->flipCount;
        
        JCSHexDirection direction = moveInfo->direction;
        NSInteger rowDelta = JCSHexDirectionRowDelta(direction);
        NSInteger columnDelta = JCSHexDirectionColumnDelta(direction);
        
        BOOL stop = NO;
        
        // invoke block for start cell, flipped cells, and target cell (total: flipCount+2 cells)
        NSInteger startRow = moveInfo->startRow;
        NSInteger startColumn = moveInfo->startColumn;
        for (NSInteger j = 0; j <= flipCount+1 && !stop; j++) {
            NSInteger i = (reverse ? (flipCount+1-j) : j);
            NSInteger curRow = startRow + i * rowDelta;
            NSInteger curColumn = startColumn + i * columnDelta;
            JCSFlipCellState newCellState = [self cellStateAtRow:curRow column:curColumn];
            JCSFlipCellState oldCellState;
            if (i == 0) {
                // start cell
                oldCellState = newCellState;
            } else if (i == flipCount+1) {
                // target cell
                oldCellState = JCSFlipCellStateEmpty;
            } else {
                // flipped cell
                oldCellState = JCSFlipCellStateOther(newCellState);
            }
            block(curRow, curColumn, oldCellState, newCellState, &stop);
        }
    }
}

#pragma mark JCSGameNode

- (BOOL)leaf {
    return JCSFlipGameStatusIsOver(self.status);
}

- (void)applyAllPossibleMovesAndInvokeBlock:(void(^)(id<JCSMove> move, BOOL *stop))block {
    NSAssert(block != nil, @"block must not be nil");
    
    if (JCSFlipGameStatusIsOver(self.status)) {
        // skipping is not allowed
        _skipAllowed = JCSFlipGameStateSkipAllowedNo;
        
        // no need to try any moves
        return;
    }
    
    JCSFlipCellState playerCellState = JCSFlipCellStateForPlayerSide(_playerToMove);
    
    __block BOOL hasValidMove = NO;
    
    // initialize dummy move
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:0 startColumn:0 direction:JCSHexDirectionE];
    
    // indexes of target cells that already were the target of a no-flip move
    BOOL *isNoFlipTargetCellIndex = calloc(JCS_CELL_COUNT(_size), sizeof(BOOL));
    
    [self forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
        // try cells with the correct owner as starting cells
        if (cellState == playerCellState) {
            // update move data
            move.startRow = row;
            move.startColumn = column;
            
            // try all directions, but stop if the block says to do so
            for (JCSHexDirection direction = JCSHexDirectionMin; direction <= JCSHexDirectionMax && !*stop; direction++) {
                move.direction = direction;
                
                // determine neighbor cell to check for no-flip move
                NSInteger nbrRow = row + JCSHexDirectionRowDelta(direction);
                NSInteger nbrColumn = column + JCSHexDirectionColumnDelta(direction);
                JCSFlipCellState nbrCellState = [self cellStateAtRow:nbrRow column:nbrColumn];
                if (nbrCellState == JCSFlipCellStateEmpty) {
                    // neighbor cell is empty, this is a no-flip move
                    NSInteger targetIndex = JCS_CELL_STATE_INDEX(_size, nbrRow, nbrColumn);
                    if (isNoFlipTargetCellIndex[targetIndex]) {
                        // this no-flip move is equivalent to another no-flip move that has already been scanned
                        continue;
                    }
                    // mark target cell index, and continue with the move
                    isNoFlipTargetCellIndex[targetIndex] = YES;
                }
                
                // try the move
                if ([self pushMove:move]) {
                    // move is valid - invoke block with move copy
                    block([move copy], stop);
                    
                    // undo the move
                    [self popMove];
                    
                    // we have a move
                    hasValidMove = YES;
                }
            }
        }
    }];
    
    // release the no-flip move detection array
    free(isNoFlipTargetCellIndex);
    
    if (!hasValidMove) {
        // skipping is allowed
        _skipAllowed = JCSFlipGameStateSkipAllowedYes;
        
        // update move date
        move.skip = YES;
        
        // apply skip move
        if ([self pushMove:move]) {
            // move is valid - invoke block with dummy stop flag (no need to copy the move here)
            BOOL stop = NO;
            block(move, &stop);
            
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
        if (startCellState != JCSFlipCellStateForPlayerSide(_playerToMove)) {
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
    
    // duplicate stack capacity if stack is full
    if (_moveInfoStackTop == _moveInfoStackCapacity) {
        _moveInfoStackCapacity *= 2;
        _moveInfoStack = realloc(_moveInfoStack, _moveInfoStackCapacity*sizeof(JCSFlipGameStateMoveInfo));
    }
    
    // reserve next free stack entry
    JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStack + _moveInfoStackTop++;
    
    // populate move info
    moveInfo->skip = move.skip;
    if (!moveInfo->skip) {
        moveInfo->startRow = move.startRow;
        moveInfo->startColumn = move.startColumn;
        moveInfo->direction = move.direction;
    }
    moveInfo->flipCount = flipCount;
    moveInfo->oldSkipAllowed = _skipAllowed;
    
    // switch players, XOR out of and into Zobrist hash
    _playerToMove = JCSFlipPlayerSideOther(_playerToMove);
    _zobristHash ^= _zobristHashPartPlayerAToMove ^ _zobristHashPartPlayerBToMove;
    
    // "skip allowed" flag needs to be determined
    _skipAllowed = JCSFlipGameStateSkipAllowedUnknown;
    
    // move successful
    return YES;
}

- (void)popMove {
    // pop the move info from the stack
    NSAssert(_moveInfoStackTop != 0, @"move stack is empty");
    JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStack + --_moveInfoStackTop;
    
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
    
    // switch back players, XOR out of and into Zobrist hash
    _playerToMove = JCSFlipPlayerSideOther(_playerToMove);
    _zobristHash ^= _zobristHashPartPlayerAToMove ^ _zobristHashPartPlayerBToMove;
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
    if (_moveInfoStackTop == 0) {
        return nil;
    }
    JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStack + _moveInfoStackTop-1;
    if (moveInfo->skip == YES) {
        return [JCSFlipMove moveSkip];
    }
    return [JCSFlipMove moveWithStartRow:moveInfo->startRow startColumn:moveInfo->startColumn direction:moveInfo->direction];
}

#pragma mark NSCoding (serialization/deserialization)

NSString *coderKey_size = @"a";
NSString *coderKey_playerToMove = @"b";
NSString *coderKey_cellStates = @"c";
NSString *coderKey_moveStackArray = @"d";

// converts the move stack to an array, converting no more than the given number of moves
// stack top comes last in array
- (NSArray *)createArrayFromMoveStackWithMaxMoves:(NSUInteger)maxMoves {
    NSMutableArray *array = [NSMutableArray array];
    
    NSUInteger moves = MIN(maxMoves, _moveInfoStackTop);
    for (NSUInteger i = 0; i < moves; i++) {
        JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStack + _moveInfoStackTop - moves + i;
        [array addObject:@(moveInfo->skip)];
        [array addObject:@(moveInfo->startRow)];
        [array addObject:@(moveInfo->startColumn)];
        [array addObject:@(moveInfo->direction)];
        [array addObject:@(moveInfo->flipCount)];
        [array addObject:@(moveInfo->oldSkipAllowed)];
    }
    
    // return immutable copy
    return [array copy];
}

// converts the array to a move stack, starting at the specified index
// stack top comes last in array
- (void)populateMoveStackFromArray:(NSArray *)array {
    NSUInteger index = 0;
    
    while (index < array.count) {
        // duplicate stack capacity if stack is full
        if (_moveInfoStackTop == _moveInfoStackCapacity) {
            _moveInfoStackCapacity *= 2;
            _moveInfoStack = realloc(_moveInfoStack, _moveInfoStackCapacity*sizeof(JCSFlipGameStateMoveInfo));
        }
        
        // reserve next free stack entry
        JCSFlipGameStateMoveInfo *moveInfo = _moveInfoStack + _moveInfoStackTop++;
        
        // populate stack entry from array
        moveInfo->skip = [array[index++] boolValue];
        moveInfo->startRow = [array[index++] integerValue];
        moveInfo->startColumn = [array[index++] integerValue];
        moveInfo->direction = [array[index++] intValue];
        moveInfo->flipCount = [array[index++] integerValue];
        moveInfo->oldSkipAllowed = [array[index++] intValue];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder maxMoves:(NSUInteger)maxMoves {
    [aCoder encodeInteger:_size forKey:coderKey_size];
    [aCoder encodeInt:_playerToMove forKey:coderKey_playerToMove];
    [aCoder encodeBytes:_cellStates length:JCS_CELL_COUNT(_size) forKey:coderKey_cellStates];
    [aCoder encodeObject:[self createArrayFromMoveStackWithMaxMoves:maxMoves] forKey:coderKey_moveStackArray];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // encode the full move stack
    [self encodeWithCoder:aCoder maxMoves:NSUIntegerMax];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger size = [aDecoder decodeIntegerForKey:coderKey_size];
    JCSFlipPlayerSide playerToMove = [aDecoder decodeIntForKey:coderKey_playerToMove];
    
    NSUInteger length;
    const JCSFlipCellState *cellStates = [aDecoder decodeBytesForKey:coderKey_cellStates returnedLength:&length];
    NSAssert(length == JCS_CELL_COUNT(size), @"invalid length");
    
    self = [self initWithSize:size playerToMove:playerToMove cellStateAtBlock:^JCSFlipCellState(NSInteger row, NSInteger column) {
        return cellStates[JCS_CELL_STATE_INDEX(size, row, column)];
    }];
    
    [self populateMoveStackFromArray:[aDecoder decodeObjectForKey:coderKey_moveStackArray]];
    
    return self;
}

@end
