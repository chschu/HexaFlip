//
//  JCSFlipUIBoardLayer.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBoardLayer.h"
#import "JCSFlipUICellNode.h"

@implementation JCSFlipUIBoardLayer {
    // the child nodes representing the cells
    // key: "row:column"
    // value: (JCSFlipUICellNode *) at that coordinate
    NSDictionary *_uiCellNodes;
    
    // selected starting cell for tap-tap move input
    // not used for drag move input
    JCSFlipUICellNode *_moveStartCell;
    
    // direction of the move for tap-tap move input
    // not used for drag move input
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
        if (_moveStartCell == nil) {
            // first tap of tap-tap or start of drag move input
            return [_inputDelegate inputSelectedStartRow:cell.row startColumn:cell.column];
        } else {
            // second tap of tap-tap move input
            
            if (cell.cellState != JCSFlipCellStateEmpty) {
                // second tap cell is not empty
                // cancel move input and notify delegate
                _moveStartCell = nil;
                [_inputDelegate inputCancelled];
                return NO;
            }
            
            NSInteger dr = cell.row - _moveStartCell.row;
            NSInteger dc = cell.column - _moveStartCell.column;
            if (!(dr == 0 || dc == 0 || dr+dc == 0)) {
                // not a straight line between the two tapped cells
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
            } else if (dr+dc == 0) {
                if (dr > 0) {
                    _moveDirection = JCSHexDirectionNW;
                } else {
                    _moveDirection = JCSHexDirectionSE;
                }
            } else {
                // not a straight line
                // cancel move input and notify delegate
                _moveStartCell = nil;
                [_inputDelegate inputCancelled];
                return NO;
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
                // cancel move input and notify delegate
                _moveStartCell = nil;
                [_inputDelegate inputCancelled];
                return NO;
            }
            
            // accept the direction
            [_inputDelegate inputSelectedDirection:_moveDirection];
            return YES;
        }
    } else {
        return NO;
    }
}

- (void)touchWithCell:(JCSFlipUICellNode *)cell dragged:(CGPoint)dragged {
    if (hypot(dragged.x, dragged.y) >= 0.5) {
        if (_moveStartCell == nil) {
            // dragged out during first tap
            
            // determine direction from angle in radians (ccw, 0 is positive x, i.e. east)
            JCSHexDirection direction = JCSHexDirectionForAngle(atan2f(dragged.y, dragged.x));
            
            // notify delegate
            [_inputDelegate inputSelectedDirection:direction];
        } else {
            // dragged out during second tap of tap-tap move input
            
            // clear the direction selection
            [_inputDelegate inputClearedDirection];
        }
    } else {
        if (_moveStartCell == nil) {
            // dragged back in during first tap
            
            // clear the direction selection
            [_inputDelegate inputClearedDirection];
        } else {
            // dragged back in during second tap of tap-tap move input
            
            // set the direction again
            [_inputDelegate inputSelectedDirection:_moveDirection];
        }
    }
}

- (void)touchEndedWithCell:(JCSFlipUICellNode *)cell dragged:(CGPoint)dragged {
    if (hypot(dragged.x, dragged.y) >= 0.5) {
        if (_moveStartCell == nil) {
            // drag move input
            
            // determine direction from angle in radians (ccw, 0 is positive x, i.e. east)
            JCSHexDirection direction = JCSHexDirectionForAngle(atan2f(dragged.y, dragged.x));
            
            // execute the move
            JCSFlipMove *move = [JCSFlipMove moveWithStartRow:cell.row startColumn:cell.column direction:direction];
            [_inputDelegate inputConfirmedWithMove:move];
        } else {
            // dragged out during second tap of tap-tap move input
            
            // clear the direction selection
            [_inputDelegate inputClearedDirection];
        }
    } else {
        if (_moveStartCell == nil) {
            // first tap of tap-tap move input
            
            // set the start cell for tap-tap move input
            _moveStartCell = cell;
        } else {
            // second tap of tap-tap move input
            
            // execute the move
            JCSFlipMove *move = [JCSFlipMove moveWithStartRow:_moveStartCell.row startColumn:_moveStartCell.column direction:_moveDirection];
            [_inputDelegate inputConfirmedWithMove:move];
        }
    }
}

- (void)touchCancelledWithCell:(JCSFlipUICellNode *)cell {
    // clear state and notify delegate
    _moveStartCell = nil;
    [_inputDelegate inputCancelled];
}

@end
