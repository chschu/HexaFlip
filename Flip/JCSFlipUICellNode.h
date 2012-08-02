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

@interface JCSFlipUICellNode : CCNode <CCTargetedTouchDelegate>

@property (readonly) NSInteger row;
@property (readonly) NSInteger column;
@property (assign, nonatomic) JCSFlipCellState cellState;

// the delegate to report touches to
@property (weak, nonatomic) id<JCSFlipUICellNodeTouchDelegate> touchDelegate;

- (id)initWithRow:(NSInteger)row column:(NSInteger)column cellState:(JCSFlipCellState)cellState;

@end
