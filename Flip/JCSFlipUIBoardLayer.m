//
//  JCSFlipUIBoardLayer.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBoardLayer.h"
#import "JCSFlipUICellNode.h"

// states for move input
typedef enum {
    JCSFlipUIMoveInputStateReady, // ready for move input
    JCSFlipUIMoveInputStateFirstTapInside, // first tap, drag position inside start cell
    JCSFlipUIMoveInputStateFirstTapOutside,  // first tap, drag position outside start cell
    JCSFlipUIMoveInputStateFirstTapSelected,  // first tap, selected by releasing inside start cell
    JCSFlipUIMoveInputStateSecondTapInside, // second tap, drag position inside target cell
    JCSFlipUIMoveInputStateSecondTapOutside,  // second tap, drag position outside target cell
} JCSFlipUIMoveInputState;

@implementation JCSFlipUIBoardLayer {
    // the child nodes representing the cells
    // key: "row:column"
    // value: (JCSFlipUICellNode *) at that coordinate
    NSDictionary *_uiCellNodes;

    // move input state
    JCSFlipUIMoveInputState _moveInputState;
    
    // selected starting cell
    JCSFlipUICellNode *_moveStartCell;
    
    // current direction of the potential move
    JCSHexDirection _moveDirection;
}

@synthesize inputDelegate = _inputDelegate;
@synthesize moveInputEnabled = _moveInputEnabled;

- (id)initWithState:(JCSFlipGameState *)state {
    if (self = [super init]) {
        _uiCellNodes = [NSMutableDictionary dictionary];
        
        [state forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
            JCSFlipUICellNode *uiCell = [[JCSFlipUICellNode alloc] initWithRow:row column:column cellState:cellState];
            
            // remember in dictionary
            [self setCellNode:uiCell atRow:row column:column];
            
            // register as touch delegate of every cell
            uiCell.touchDelegate = self;
            
            // place cells with spacing of 1
            uiCell.position = ccp((row/2.0+column), (sqrt(3.0)*row/2.0));
            
            [self addChild:uiCell z:0];
        }];
        
        // create immutable dictionary
        _uiCellNodes = [_uiCellNodes copy];
        
        // disallow move input
        _moveInputEnabled = NO;
        _moveInputState = JCSFlipUIMoveInputStateReady;
    }
    return self;
}

- (void)animateMove:(JCSFlipMove *)move newGameState:(JCSFlipGameState *)newGameState afterAnimationInvokeBlock:(void(^)())block {
    if (move.skip) {
        // TODO: animate skip
        block();
        return;
    }
    
    NSInteger curRow = move.startRow;
    NSInteger curColumn = move.startColumn;
    NSInteger rowDelta = JCSHexDirectionRowDelta(move.direction);
    NSInteger columnDelta = JCSHexDirectionColumnDelta(move.direction);
    
    NSMutableArray *actions = [NSMutableArray array];
    
    ccTime delay = 0;
    
    // iterate to flip cells
    while (YES) {
        JCSFlipCellState newCellState = [newGameState cellStateAtRow:curRow column:curColumn];
        JCSFlipUICellNode *uiCell = [self cellNodeAtRow:curRow column:curColumn];
        
        if (uiCell.cellState == newCellState && (curRow != move.startRow || curColumn != move.startColumn)) {
            break;
        }
        
        // create animation
        float oldScale = uiCell.scale;
        float newScale = (uiCell.cellState == newCellState ? oldScale*0.5 : 0.0);
        id hideAction = [CCScaleTo actionWithDuration:0.3 scale:newScale];
        id updateAction = [CCCallBlock actionWithBlock:^{
            uiCell.cellState = newCellState;
        }];
        id setZOrderAction = [CCCallBlock actionWithBlock:^{
            // bring to front
            uiCell.zOrder = 1;
        }];
        id showAction = [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:oldScale] period:0.3];
        id resetZOrderAction = [CCCallBlock actionWithBlock:^{
            // put back
            uiCell.zOrder = 0;
        }];
        
        // create action array to be spawned
        NSArray *animActions = [NSArray arrayWithObjects:
                                [CCDelayTime actionWithDuration:delay],
                                [CCTargetedAction actionWithTarget:uiCell action:hideAction],
                                updateAction,
                                setZOrderAction,
                                [CCTargetedAction actionWithTarget:uiCell action:showAction],
                                resetZOrderAction,
                                nil];
        
        [actions addObject:[CCSequence actionWithArray:animActions]];
        
        curRow += rowDelta;
        curColumn += columnDelta;
        delay += 0.1;
    }
    
    id fullAnimationAction = [CCSpawn actionWithArray:actions];
    
    id finalBlockAction = [CCCallBlock actionWithBlock:^{
        block();
    }];
    
    // create sequence of animation and notification
    NSArray *sequenceActions = [NSArray arrayWithObjects:
                                fullAnimationAction,
                                finalBlockAction,
                                nil];
    
    [self runAction:[CCSequence actionWithArray:sequenceActions]];
}

- (void)setCellNode:(JCSFlipUICellNode *)cellNode atRow:(NSInteger)row column:(NSInteger)column {
    [_uiCellNodes setValue:cellNode forKey:[NSString stringWithFormat:@"%d:%d", row, column]];
}

- (JCSFlipUICellNode *)cellNodeAtRow:(NSInteger)row column:(NSInteger)column {
    return [_uiCellNodes valueForKey:[NSString stringWithFormat:@"%d:%d", row, column]];
}

- (BOOL)touchBeganWithCell:(JCSFlipUICellNode *)cell {
    if (_moveInputEnabled) {
        switch (_moveInputState) {
            case JCSFlipUIMoveInputStateReady:
                if ([_inputDelegate inputSelectedStartRow:cell.row startColumn:cell.column]) {
                    _moveStartCell = cell;
                    _moveInputState = JCSFlipUIMoveInputStateFirstTapInside;
                    return YES;
                }
                return NO;
                
            case JCSFlipUIMoveInputStateFirstTapSelected:
                if (cell == _moveStartCell) {
                    // tapped the same cell twice
                    
                    // cancel move input and discard touch
                    [_inputDelegate inputClearedStartRow:_moveStartCell.row startColumn:_moveStartCell.column];
                    [_inputDelegate inputCancelled];
                    _moveInputState = JCSFlipUIMoveInputStateReady;
                    return NO;
                }
                
                if (cell.cellState != JCSFlipCellStateEmpty) {
                    // second tap cell is not empty
                    
                    // discard touch
                    return NO;
                }

                NSInteger dr = cell.row - _moveStartCell.row;
                NSInteger dc = cell.column - _moveStartCell.column;
                if (!(dr == 0 || dc == 0 || dr+dc == 0)) {
                    // not a straight line between the two tapped cells
                    
                    // discard touch
                    return NO;
                }
                
                // determine direction for tap-tap move input
                if (dr == 0) {
                    if (dc > 0) {
                        _moveDirection = JCSHexDirectionE;
                    } else {
                        _moveDirection = JCSHexDirectionW;
                    }
                } else if (dc == 0) {
                    if (dr > 0) {
                        _moveDirection = JCSHexDirectionNE;
                    } else {
                        _moveDirection = JCSHexDirectionSW;
                    }
                } else { // dr+dc == 0
                    if (dr > 0) {
                        _moveDirection = JCSHexDirectionNW;
                    } else {
                        _moveDirection = JCSHexDirectionSE;
                    }
                }
                
                // check that the second tap is on the first empty cell in that direction
                NSInteger curRow = _moveStartCell.row;
                NSInteger curColumn = _moveStartCell.column;
                NSInteger rowDelta = JCSHexDirectionRowDelta(_moveDirection);
                NSInteger columnDelta = JCSHexDirectionColumnDelta(_moveDirection);
                JCSFlipCellState curState;
                while ((curState = [self cellNodeAtRow:curRow column:curColumn].cellState) != JCSFlipCellStateEmpty) {
                    curRow += rowDelta;
                    curColumn += columnDelta;
                }
                if (curRow != cell.row || curColumn != cell.column) {
                    // not the first empty cell in that direction
                    
                    // discard touch
                    return NO;
                }
                
                // accept the direction
                _moveInputState = JCSFlipUIMoveInputStateSecondTapInside;
                [_inputDelegate inputSelectedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                
                // keep track of the touch
                return YES;
                
            default:
                NSAssert(NO, @"illegal move input state %d", _moveInputState);
                return NO;
        }
    } else {
        return NO;
    }
}

- (void)touchWithCell:(JCSFlipUICellNode *)cell dragged:(CGPoint)dragged ended:(BOOL)ended {
    BOOL inside = (hypot(dragged.x, dragged.y) <= 0.5);

    // track inside/outside changes
    switch (_moveInputState) {
        case JCSFlipUIMoveInputStateFirstTapInside:
            if (!inside) {
                // set direction
                _moveDirection = JCSHexDirectionForAngle(atan2f(dragged.y, dragged.x));
                [_inputDelegate inputSelectedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                _moveInputState = JCSFlipUIMoveInputStateFirstTapOutside;
            }
            break;
        
        case JCSFlipUIMoveInputStateFirstTapOutside:
            if (inside) {
                [_inputDelegate inputClearedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                _moveInputState = JCSFlipUIMoveInputStateFirstTapInside;
            } else {
                // update direction
                JCSHexDirection oldDirection = _moveDirection;
                _moveDirection = JCSHexDirectionForAngle(atan2f(dragged.y, dragged.x));
                if (_moveDirection != oldDirection) {
                    [_inputDelegate inputClearedDirection:oldDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                    [_inputDelegate inputSelectedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                }
            }
            break;

        case JCSFlipUIMoveInputStateSecondTapInside:
            if (!inside) {
                // hide direction
                [_inputDelegate inputClearedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                _moveInputState = JCSFlipUIMoveInputStateSecondTapOutside;
            }
            break;

        case JCSFlipUIMoveInputStateSecondTapOutside:
            if (inside) {
                // show direction
                [_inputDelegate inputSelectedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                _moveInputState = JCSFlipUIMoveInputStateSecondTapInside;
            }
            break;

        default:
            NSAssert(NO, @"illegal move input state %d", _moveInputState);
            break;
    }

    // move/cancel stage
    if (ended) {
        JCSFlipMove *move;
        switch (_moveInputState) {
            case JCSFlipUIMoveInputStateFirstTapInside:
                // released inside start cell: initiate tap-tap move input
                _moveInputState = JCSFlipUIMoveInputStateFirstTapSelected;
                break;

            case JCSFlipUIMoveInputStateFirstTapOutside:
                // released outside start cell: complete drag move input
                [_inputDelegate inputClearedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                [_inputDelegate inputClearedStartRow:_moveStartCell.row startColumn:_moveStartCell.column];
                move = [JCSFlipMove moveWithStartRow:_moveStartCell.row startColumn:_moveStartCell.column direction:_moveDirection];
                [_inputDelegate inputConfirmedWithMove:move];
                _moveInputState = JCSFlipUIMoveInputStateReady;
                break;
            
            case JCSFlipUIMoveInputStateSecondTapInside:
                // released inside target cell: complete tap-tap move input
                [_inputDelegate inputClearedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
                [_inputDelegate inputClearedStartRow:_moveStartCell.row startColumn:_moveStartCell.column];
                move = [JCSFlipMove moveWithStartRow:_moveStartCell.row startColumn:_moveStartCell.column direction:_moveDirection];
                [_inputDelegate inputConfirmedWithMove:move];
                _moveInputState = JCSFlipUIMoveInputStateReady;
                break;
                
            case JCSFlipUIMoveInputStateSecondTapOutside:
                // released outside target cell: rewind to tap-tap direction input
                _moveInputState = JCSFlipUIMoveInputStateFirstTapSelected;
                break;
                
            default:
                NSAssert(NO, @"illegal move input state %d", _moveInputState);
                break;
        }
    }
}

- (void)touchCancelledWithCell:(JCSFlipUICellNode *)cell {
    switch (_moveInputState) {
        case JCSFlipUIMoveInputStateFirstTapInside:
            [_inputDelegate inputClearedStartRow:_moveStartCell.row startColumn:_moveStartCell.column];
            [_inputDelegate inputCancelled];
            _moveInputState = JCSFlipUIMoveInputStateReady;
            break;
            
        case JCSFlipUIMoveInputStateFirstTapOutside:
            [_inputDelegate inputClearedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
            [_inputDelegate inputClearedStartRow:_moveStartCell.row startColumn:_moveStartCell.column];
            [_inputDelegate inputCancelled];
            _moveInputState = JCSFlipUIMoveInputStateReady;
            break;
            
        case JCSFlipUIMoveInputStateFirstTapSelected:
            break;
        
        case JCSFlipUIMoveInputStateSecondTapInside:
            [_inputDelegate inputClearedDirection:_moveDirection startRow:_moveStartCell.row startColumn:_moveStartCell.column];
            _moveInputState = JCSFlipUIMoveInputStateFirstTapSelected;
            break;
            
        case JCSFlipUIMoveInputStateSecondTapOutside:
            _moveInputState = JCSFlipUIMoveInputStateFirstTapSelected;
            break;
            
        default:
            NSAssert(NO, @"illegal move input state %d", _moveInputState);
            break;
    }
}

- (void)startFlashForCellAtRow:(NSInteger)row column:(NSInteger)column {
    [[self cellNodeAtRow:row column:column] startFlash];
}

- (void)stopFlashForCellAtRow:(NSInteger)row column:(NSInteger)column {
    [[self cellNodeAtRow:row column:column] stopFlash];
}

@end
