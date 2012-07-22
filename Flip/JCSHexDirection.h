//
//  JCSHexDirection.h
//  Flip
//
//  Created by Christian Schuster on 17.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef enum {
    JCSHexDirectionE,
    JCSHexDirectionNE,
    JCSHexDirectionNW,
    JCSHexDirectionW,
    JCSHexDirectionSW,
    JCSHexDirectionSE,
} JCSHexDirection;

#define JCSHexDirectionMin JCSHexDirectionE
#define JCSHexDirectionMax JCSHexDirectionSE

#define JCSHexDirectionRowDelta(direction) ((direction) == JCSHexDirectionNE || (direction) == JCSHexDirectionNW) - ((direction) == JCSHexDirectionSW || (direction) == JCSHexDirectionSE)
#define JCSHexDirectionColumnDelta(direction) ((direction) == JCSHexDirectionE || (direction) == JCSHexDirectionSE) - ((direction) == JCSHexDirectionW || (direction) == JCSHexDirectionNW)
