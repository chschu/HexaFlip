//
//  JCSFlipPlayerAI.h
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"
#import "JCSGameAlgorithm.h"
#import "JCSFlipMoveInputDelegate.h"

@interface JCSFlipPlayerAI : NSObject <JCSFlipPlayer>

@property (strong, readonly) id<JCSGameAlgorithm> algorithm;

// create an AI player with name, algorithm, and a delegate to perform the move input
+ (id)playerWithName:(NSString *)name algorithm:(id<JCSGameAlgorithm>)algorithm moveInputDelegate:(id<JCSFlipMoveInputDelegate>)moveInputDelegate;

@end
