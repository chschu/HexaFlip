//
//  JCSHexDirection.h
//  HexaFlip
//
//  Created by Christian Schuster on 17.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

typedef NS_ENUM(int, JCSHexDirection) {
    JCSHexDirectionE = 0,
    JCSHexDirectionNE = 1,
    JCSHexDirectionNW = 2,
    JCSHexDirectionW = 3,
    JCSHexDirectionSW = 4,
    JCSHexDirectionSE = 5,
};

#define JCSHexDirectionMin JCSHexDirectionE
#define JCSHexDirectionMax JCSHexDirectionSE

#define JCSHexDirectionRowDelta(direction) ({ \
__typeof__(direction) _d = (direction); \
(_d == JCSHexDirectionNE || _d == JCSHexDirectionNW) - (_d == JCSHexDirectionSW || _d == JCSHexDirectionSE); \
})

#define JCSHexDirectionColumnDelta(direction) ({ \
__typeof__(direction) _d = (direction); \
(_d == JCSHexDirectionE || _d == JCSHexDirectionSE) - (_d == JCSHexDirectionW || _d == JCSHexDirectionNW); \
})

// direction for a given angle (in radians)
// 0 is East, Pi/3 is Northeast, etc.
#define JCSHexDirectionForAngle(angle) ((JCSHexDirection) (fmod(fmod((angle),2.0*M_PI)+2.0*M_PI+M_PI/6,2.0*M_PI) / (M_PI/3)))

// string representation of the direction
#define JCSHexDirectionName(direction) ({ \
__typeof__(direction) _d = (direction); \
_d == JCSHexDirectionE ? @"E" : \
_d == JCSHexDirectionNE ? @"NE" : \
_d == JCSHexDirectionNW ? @"NW" : \
_d == JCSHexDirectionW ? @"W" : \
_d == JCSHexDirectionSW ? @"SW" : @"SE"; \
})
