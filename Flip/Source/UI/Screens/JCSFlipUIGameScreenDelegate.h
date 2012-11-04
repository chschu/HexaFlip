//
//  JCSFlipUIGameScreenDelegate.h
//  Flip
//
//  Created by Christian Schuster on 04.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"

@protocol JCSFlipUIGameScreenDelegate <NSObject>

- (void)gameEndedWithStatus:(JCSFlipGameStatus)status;

@end
