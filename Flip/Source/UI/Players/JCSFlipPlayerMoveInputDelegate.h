//
//  JCSFlipMoveInputDelegate.h
//  Flip
//
//  Created by Christian Schuster on 27.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexDirection.h"

@class JCSFlipMove;

// protocol used for notification of move input
// can be used to visualize the different stages of move input
//
// basically, each "selected" message is compensated with a corresponding "cleared" message
//
// exception: if -inputSelectedStartRow:startColumn: disallows the input (i.e. returns NO),
// no such compensation is required
//
// example invocation order:
// -inputSelectedStartRow:startColumn:
// -inputSelectedDirection:startRow:startColumn: (after first direction choice)
// -inputClearedDirection:startRow:startColumn: (before second direction choice)
// -inputClearedDirection:startRow:startColumn: (clear for final selected direction)
// -inputClearedStartRow:startColumn: (clear for start cell)
// -inputConfirmedWithMove:
@protocol JCSFlipPlayerMoveInputDelegate <NSObject>

// the player has selected a row and column to start the move
// the delegate must return YES if the selection is valid, NO if it is not
- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn;

// the start cell selection has been cleared
// the previously selected start cell coordinated are given
- (void)inputClearedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn;

// the player has selected a direction (might be invoked multiple times)
// the startRow and startColumn are always the values passed to -inputSelectedStartRow:startColumn:
- (void)inputSelectedDirection:(JCSHexDirection)direction startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn;

// the direction selection has been cleared
// the direction, startRow, and startColumn are always the values passed to -inputSelectedDirection:startRow:startColumn:
- (void)inputClearedDirection:(JCSHexDirection)direction startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn;

// the player has cancelled move input
// this is invoked after direction and start cell have been cleared
- (void)inputCancelled;

// the player has confirmed the move with the given data
// this is invoked after direction and start cell have been cleared
// it is actually sufficient to call only this method for each move, e.g. for AI players
- (void)inputConfirmedWithMove:(JCSFlipMove *)move;

@end
