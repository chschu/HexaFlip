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

- (void)enumerateChildrenUsingBlock:(void(^)(JCSFlipMove *move, JCSFlipGameState *nextState, BOOL *stop))block {
    [self forAllNextStatesInvokeBlock:block];
}

@end
