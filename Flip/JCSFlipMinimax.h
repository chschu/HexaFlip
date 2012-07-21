//
//  JCSFlipMinimax.h
//  Flip
//
//  Created by Christian Schuster on 21.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSFlipGameState.h"

@interface JCSFlipMinimax : NSObject

+ (JCSFlipMove *)bestMoveForState:(JCSFlipGameState *)state depth:(NSInteger)depth;

@end
