//
//  JCSHexDirection.h
//  Flip
//
//  Created by Christian Schuster on 17.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef enum {
    JCSHexDirectionE = 0,
    JCSHexDirectionNE = 1,
    JCSHexDirectionNW = 2,
    JCSHexDirectionW = 3,
    JCSHexDirectionSW = 4,
    JCSHexDirectionSE = 5,
} JCSHexDirection;

#define JCSHexDirectionMin JCSHexDirectionE
#define JCSHexDirectionMax JCSHexDirectionSE

#define JCSHexDirectionRowDelta(direction) ((direction) == JCSHexDirectionNE || (direction) == JCSHexDirectionNW) - ((direction) == JCSHexDirectionSW || (direction) == JCSHexDirectionSE)
#define JCSHexDirectionColumnDelta(direction) ((direction) == JCSHexDirectionE || (direction) == JCSHexDirectionSE) - ((direction) == JCSHexDirectionW || (direction) == JCSHexDirectionNW)

// direction for a given angle (in radians)
// 0 is East, Pi/3 is Northeast, etc.
#define JCSHexDirectionForAngle(angle) ((JCSHexDirection) (fmod(fmod((angle),2.0*M_PI)+2.0*M_PI+M_PI/6,2.0*M_PI) / (M_PI/3)))