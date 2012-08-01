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
            
            // register as input delegate of every cell
            uiCell.inputDelegate = self;
            
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
        id showAction = [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:oldScale] period:0.5];
        
        // create action array to be spawned
        NSArray *animActions = [NSArray arrayWithObjects:
                                [CCDelayTime actionWithDuration:delay],
                                [CCTargetedAction actionWithTarget:uiCell action:hideAction],
                                updateAction,
                                [CCTargetedAction actionWithTarget:uiCell action:showAction],
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

- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn {
    if (_moveInputEnabled) {
        return [_inputDelegate inputSelectedStartRow:startRow startColumn:startColumn];
    } else {
        return NO;
    }
}

- (void)inputSelectedDirection:(JCSHexDirection)direction {
    [_inputDelegate inputSelectedDirection:direction];
}

- (BOOL)inputConfirmedWithMove:(JCSFlipMove *)move {
    return [_inputDelegate inputConfirmedWithMove:move];
}

- (void)inputCancelled {
    [_inputDelegate inputCancelled];
}

@end
