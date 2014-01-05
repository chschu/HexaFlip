//
//  JCSFlipUICellNode.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipCellState.h"

#import "cocos2d.h"

@protocol JCSFlipUICellNodeTouchDelegate;

@interface JCSFlipUICellNode : CCSprite <CCTouchOneByOneDelegate>

@property (readonly, nonatomic) NSInteger row;
@property (readonly, nonatomic) NSInteger column;
@property (readonly, nonatomic) JCSFlipCellState cellState;

// the delegate to report touches to
@property (weak, nonatomic) id<JCSFlipUICellNodeTouchDelegate> touchDelegate;

// the background sprite (can be used for individual rotation)
@property (readonly, nonatomic) CCSprite *backgroundSprite;

+ (instancetype)nodeWithRow:(NSInteger)row column:(NSInteger)column cellState:(JCSFlipCellState)cellState;

// repeatedly flash the cell
// restarts flashing if the cell is already flashing
- (void)startFlash;

// stops the cell's flashing
// no-op if the cell is not flashing
- (void)stopFlash;

// create an action that animates the cell state change
- (CCFiniteTimeAction *)createAnimationForChangeToCellState:(JCSFlipCellState)newCellState;

@end
