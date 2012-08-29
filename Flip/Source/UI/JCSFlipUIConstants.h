//
//  JCSFlipUIConstants.h
//  Flip
//
//  Created by Christian Schuster on 21.08.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

// distance between cell centers in points
const float JCS_FLIP_UI_CELL_SPACING_POINTS = 38.0;

// empty border around the cells in the board layer, in points
// used for layout (if the board is aligned to a border)
const float JCS_FLIP_UI_BOARD_BORDER = 10.0;

// distance in points that a touch must be dragged away from the center of the touched cell to be considered "outside" that cell
// larger values avoid accidentially selecting a direction, but require a longer dragging distance
// larget values may prohibit proper selection of a direction with the starting cell near a border
const float JCS_FLIP_UI_DRAG_OUTSIDE_THRESHOLD = JCS_FLIP_UI_CELL_SPACING_POINTS;