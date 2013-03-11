//
//  JCSFlipGameState+GameNode.m
//  HexaFlip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState+GameNode.h"
#import "JCSFlipGameStatus.h"
#import "JCSFlipPlayerToMove.h"

@implementation JCSFlipGameState (GameNode)

- (BOOL)leaf {
    return JCSFlipGameStatusIsOver(self.status);
}

// the other protocol methods are already implemented in JCSFlipGameState

@end
