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