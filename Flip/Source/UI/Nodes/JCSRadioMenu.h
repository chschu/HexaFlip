//
//  JCSRadioMenu.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

@interface JCSRadioMenu : CCMenu

@property (nonatomic) CCMenuItem *selectedItem;

// when set to YES, disables all menu items and shows them in their "selected" state
// this does not influence the selectedItem property
@property (nonatomic) BOOL allSelectedMode;

@end
