//
//  JCSFlipUICellNode.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "CCNode.h"
#import "JCSFlipCellState.h"
#import "JCSFlipUICellNodeTouchDelegate.h"

#import "cocos2d.h"

@interface JCSFlipUICellNode : CCSprite <CCTargetedTouchDelegate>

@property (readonly, nonatomic) NSInteger row;
@property (readonly, nonatomic) NSInteger column;
@property (readonly, nonatomic) JCSFlipCellState cellState;

// the delegate to report touches to
@property (weak, nonatomic) id<JCSFlipUICellNodeTouchDelegate> touchDelegate;

+ (id)nodeWithRow:(NSInteger)row column:(NSInteger)column cellState:(JCSFlipCellState)cellState;

// repeatedly flash the cell
// restarts flashing if the cell is already flashing
- (void)startFlash;

// stops the cell's flashing
// no-op if the cell is not flashing
- (void)stopFlash;

// create an action that animates the cell state change
- (CCFiniteTimeAction *)createAnimationForChangeToCellState:(JCSFlipCellState)newCellState;

@end
