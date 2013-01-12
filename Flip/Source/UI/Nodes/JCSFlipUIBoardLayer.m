//
//  JCSFlipUIBoardLayer.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIConstants.h"
#import "JCSFlipUIBoardLayer.h"
#import "JCSFlipUICellNode.h"
#import "JCSHexDirection.h"
#import "JCSFlipGameState.h"
#import "JCSFlipPlayerMoveInputDelegate.h"
#import "JCSFlipMove.h"

// states for move input
typedef enum {
    JCSFlipUIMoveInputStateReady = 0, // ready for move input
    JCSFlipUIMoveInputStateFirstTapInside = 1, // first tap, drag position inside start cell
    JCSFlipUIMoveInputStateFirstTapOutside = 2,  // first tap, drag position outside start cell
    JCSFlipUIMoveInputStateFirstTapSelected = 3,  // first tap, selected by releasing inside start cell
    JCSFlipUIMoveInputStateSecondTapInside = 4, // second tap, drag position inside target cell
    JCSFlipUIMoveInputStateSecondTapOutside = 5,  // second tap, drag position outside target cell
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

+ (id)nodeWithState:(JCSFlipGameState *)state {
    return [[self alloc] initWithState:state];
}

- (id)initWithState:(JCSFlipGameState *)state {
    if (self = [super init]) {
        _uiCellNodes = [NSMutableDictionary dictionary];
        
        CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cell-empty.png"];
        
        CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture];
        
        __block float maxAbsX = 0.0;
        __block float maxAbsY = 0.0;
        
        // add the board background (rotated by 60 degrees)
        CCSprite *boardSprite = [CCSprite spriteWithSpriteFrameName:@"board.png"];
        boardSprite.rotation = 60;
        [batchNode addChild:boardSprite];
        
        // add the cells
        [state forAllCellsInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState cellState, BOOL *stop) {
            if (cellState != JCSFlipCellStateHole) {
                // create cell node
                JCSFlipUICellNode *uiCell = [JCSFlipUICellNode nodeWithRow:row column:column cellState:cellState];
                
                // remember in dictionary
                [self setCellNode:uiCell atRow:row column:column];
                
                // register as touch delegate of every cell
                uiCell.touchDelegate = self;
                                
                // place cells with defined spacing
                float x = JCS_FLIP_UI_CELL_SPACING_POINTS * (row/2.0+column);
                float y = JCS_FLIP_UI_CELL_SPACING_POINTS * (sqrt(3.0)*row/2.0);
                uiCell.position = ccp(x, y);
                
                // add the cell to the batch node
                [batchNode addChild:uiCell z:0];
                
                maxAbsX = max(abs(x), maxAbsX);
                maxAbsY = max(abs(y), maxAbsY);
            }
        }];
        
        // add the batch node to the layer
        [self addChild:batchNode z:0];
        
        // add some borders to get a reasonable content size (for positioning in the parent node)
        self.contentSize = CGSizeMake(maxAbsX + JCS_FLIP_UI_CELL_SPACING_POINTS/2.0 + JCS_FLIP_UI_BOARD_BORDER,
                                      maxAbsY + JCS_FLIP_UI_CELL_SPACING_POINTS/sqrt(3.0) + JCS_FLIP_UI_BOARD_BORDER);

        // create immutable dictionary
        _uiCellNodes = [_uiCellNodes copy];
        
        // disallow move input
        _moveInputEnabled = NO;
        _moveInputState = JCSFlipUIMoveInputStateReady;
    }
    return self;
}

- (void)animateLastMoveOfGameState:(JCSFlipGameState *)gameState afterAnimationInvokeBlock:(void(^)())block {
    
    NSMutableArray *actions = [NSMutableArray array];
    
    __block ccTime delay = 0;
    
    // create animations for involved cells
    [gameState forAllCellsInvolvedInLastMoveInvokeBlock:^(NSInteger row, NSInteger column, JCSFlipCellState oldCellState, JCSFlipCellState newCellState, BOOL *stop) {
        JCSFlipUICellNode *uiCell = [self cellNodeAtRow:row column:column];
        CCFiniteTimeAction *cellAnimation = [uiCell createAnimationForChangeToCellState:newCellState];
        CCAction *cellAnimationWithDelay = [CCSequence actionOne:[CCDelayTime actionWithDuration:delay] two:cellAnimation];
        [actions addObject:cellAnimationWithDelay];
        delay += 0.05;
    }];
    
    id finalBlockAction = [CCCallBlock actionWithBlock:^{
        block();
    }];
    
    NSArray *sequenceActions;
    
    // create sequence of animation and notification
    if ([actions count] == 0) {
        // TODO: animate skip
        sequenceActions = [NSArray arrayWithObjects:
                           finalBlockAction,
                           nil];
    } else {
        sequenceActions = [NSArray arrayWithObjects:
                           [CCSpawn actionWithArray:actions],
                           finalBlockAction,
                           nil];
    }
    
    
    // if the scene is no longer running, the actions won't start anymore
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
    BOOL inside = (hypot(dragged.x, dragged.y) <= JCS_FLIP_UI_DRAG_OUTSIDE_THRESHOLD);
    
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
