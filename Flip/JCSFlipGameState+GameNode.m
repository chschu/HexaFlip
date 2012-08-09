//
//  JCSFlipGameState+GameNode.m
//  Flip
//
//  Created by Christian Schuster on 23.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameState+GameNode.h"

@implementation JCSFlipGameState (GameNode)

- (BOOL)leaf {
    return !(self.status == JCSFlipGameStatusPlayerAToMove || self.status == JCSFlipGameStatusPlayerBToMove);
}

- (BOOL)maximizing {
    return self.status == JCSFlipGameStatusPlayerAToMove;
}

// the other protocol methods are already implemented in JCSFlipGameState

@end
