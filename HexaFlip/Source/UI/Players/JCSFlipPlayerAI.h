//
//  JCSFlipPlayerAI.h
//  HexaFlip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayer.h"

@protocol JCSGameAlgorithm;

@interface JCSFlipPlayerAI : NSObject <JCSFlipPlayer>

@property (readonly, nonatomic) id<JCSGameAlgorithm> algorithm;

// create an AI player with an algorithm
+ (instancetype)playerWithAlgorithm:(id<JCSGameAlgorithm>)algorithm;

@end
