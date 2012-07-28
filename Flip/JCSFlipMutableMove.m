//
//  JCSFlipMutableMove.m
//  Flip
//
//  Created by Christian Schuster on 28.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMutableMove.h"

@implementation JCSFlipMutableMove

@dynamic skip;
@dynamic startRow;
@dynamic startColumn;
@dynamic direction;

- (void)setSkip:(BOOL)skip {
    _skip = skip;
}

- (void)setStartRow:(NSInteger)startRow {
    _startRow = startRow;
}

- (void)setStartColumn:(NSInteger)startColumn {
    _startColumn = startColumn;
}

- (void)setDirection:(JCSHexDirection)direction {
    _direction = direction;
}

@end
