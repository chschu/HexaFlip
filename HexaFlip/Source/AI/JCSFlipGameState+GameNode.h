//
//  JCSFlipGameState+GameNode.h
//  HexaFlip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSGameNode.h"
#import "JCSFlipGameState.h"

// Adapter category to make JCSFlipGameState usable with game algorithms
@interface JCSFlipGameState (GameNode) <JCSGameNode>

@end
