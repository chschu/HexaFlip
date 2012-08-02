//
//  JCSFlipUICellNodeTouchDelegate.h
//  Flip
//
//  Created by Christian Schuster on 02.08.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

@class JCSFlipUICellNode;

// delegate passing touch information from a cell to the board
@protocol JCSFlipUICellNodeTouchDelegate <NSObject>

// user started tapping the cell
// returns YES if the touch was accepted by the delegate, NO if not
- (BOOL)touchBeganWithCell:(JCSFlipUICellNode *)cell;

// user is dragging
// the touch started at the given cell, and spans the given dragging movement
// delta is in cell-relative cartesian coordinates, i.e. ccp(1,-2) is 1 cell size right, and 2 cell sizes down
- (void)touchWithCell:(JCSFlipUICellNode *)cell dragged:(CGPoint)dragged;

// user stopped dragging
// the touch started at the given cell, and spans the given dragging movement
// delta is in cell-relative cartesian coordinates, i.e. ccp(1,-2) is 1 cell size right, and 2 cell sizes down
- (void)touchEndedWithCell:(JCSFlipUICellNode *)cell dragged:(CGPoint)dragged;

// touch has been cancelled (e.g. by incoming call)
- (void)touchCancelledWithCell:(JCSFlipUICellNode *)cell;

@end
