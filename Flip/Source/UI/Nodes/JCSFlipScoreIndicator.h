//
//  JCSFlipScoreIndicator.h
//  Flip
//
//  Created by Christian Schuster on 02.12.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "cocos2d.h"

@interface JCSFlipScoreIndicator : CCNode

- (void)setScoreA:(NSInteger)scoreA scoreB:(NSInteger)scoreB animationDuration:(ccTime)animationDuration;

@end
