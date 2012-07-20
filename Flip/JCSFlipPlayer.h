//
//  JCSFlipPlayer.h
//  Flip
//
//  Created by Christian Schuster on 17.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef enum {
    JCSFlipPlayerA,
    JCSFlipPlayerB,
} JCSFlipPlayer;

#define JCSFlipPlayerOther(player) (JCSFlipPlayerA + JCSFlipPlayerB - (player))
