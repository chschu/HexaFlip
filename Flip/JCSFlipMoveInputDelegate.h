//
//  JCSFlipMoveInputDelegate.h
//  Flip
//
//  Created by Christian Schuster on 27.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSHexDirection.h"
#import "JCSFlipMove.h"

// protocol used for notification of move input
// can be used to visualize the different stages of move input
@protocol JCSFlipMoveInputDelegate

// the player has selected a row and column to start the move
// the delegate must return YES if the selection is valid, NO if it is not
- (BOOL)inputSelectedStartRow:(NSInteger)startRow startColumn:(NSInteger)startColumn;

// the player has selected a direction (might be invoked multiple times)
- (void)inputSelectedDirection:(JCSHexDirection)direction;

// the player has cancelled move input
- (void)inputCancelled;

// the player has confirmed the move with the given data
// it is actually sufficient to call only this method for each move, e.g. for AI players
- (void)inputConfirmedWithMove:(JCSFlipMove *)move;

@end
