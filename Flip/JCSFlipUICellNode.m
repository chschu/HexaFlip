//
//  JCSFlipUICellNode.m
//  Flip
//
//  Created by Christian Schuster on 26.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUICellNode.h"

#import "cocos2d.h"

@implementation JCSFlipUICellNode {
    CCSprite *_emptyCellSprite;
    CCSprite *_playerAOverlaySprite;
    CCSprite *_playerBOverlaySprite;
}

@synthesize cellState = _cellState;
@synthesize row = _row;
@synthesize column = _column;
@synthesize inputDelegate = _inputDelegate;

- (id)initWithRow:(NSInteger)row column:(NSInteger)column cellState:(JCSFlipCellState)cellState {
    if (self = [super init]) {
        // initialize sprites
        _emptyCellSprite = [CCSprite spriteWithFile:@"cell-empty.png"];
        _playerAOverlaySprite = [CCSprite spriteWithFile:@"cell-overlay-a.png"];
        _playerBOverlaySprite = [CCSprite spriteWithFile:@"cell-overlay-b.png"];

        CGFloat width = _emptyCellSprite.texture.contentSize.width;
        CGFloat height = _emptyCellSprite.texture.contentSize.height;
        
        // must be square
        NSAssert(width == height, @"sprite must be square");

        // overlays must be of same size
        NSAssert(_playerAOverlaySprite.texture.contentSize.width == width, @"sprites must be of same size");
        NSAssert(_playerAOverlaySprite.texture.contentSize.height == height, @"sprites must be of same size");
        NSAssert(_playerBOverlaySprite.texture.contentSize.width == width, @"sprites must be of same size");
        NSAssert(_playerBOverlaySprite.texture.contentSize.height == height, @"sprites must be of same size");
        
        // sprites are 96x96 points, place in 1x1 coordinate square
        _emptyCellSprite.scale = 1.0/width;
        _playerAOverlaySprite.scale = 1.0/width;
        _playerBOverlaySprite.scale = 1.0/width;

        _row = row;
        _column = column;
        _inputDelegate = nil;

        // use property access to initialize sprite
        self.cellState = cellState;
    }
    return self;
}

- (void)onEnter {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // our sprite has node coordinates from -0.5 to 0.5
    CGRect box = CGRectMake(-0.5, -0.5, 1, 1);
    CGPoint location = [self convertTouchToNodeSpace:touch];
    if (CGRectContainsPoint(box, location)) {
        // notify delegate and swallow touch if delegate allows
        return [_inputDelegate inputSelectedStartRow:_row startColumn:_column];
    }
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // determine direction from angle in radians (ccw, 0 is positive x, i.e. east)
    JCSHexDirection direction = JCSHexDirectionForAngle(atan2f(location.y, location.x));

    // notify delegate
    [_inputDelegate inputSelectedDirection:direction];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace:touch];

    // if distance is less than 0.5, cancel the move
    if (hypot(location.x, location.y) >= 0.5) {
        // determine direction from angle in radians (ccw, 0 is positive x, i.e. east)
        JCSHexDirection direction = JCSHexDirectionForAngle(atan2f(location.y, location.x));
        
        // notify delegate
        JCSFlipMove *move = [JCSFlipMove moveWithStartRow:_row startColumn:_column direction:direction];
        [_inputDelegate inputConfirmedWithMove:move];
    } else {
        // notify delegate
        [_inputDelegate inputCancelled];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    // notify delegate
    [_inputDelegate inputCancelled];
}

- (void)setCellState:(JCSFlipCellState)cellState {
    _cellState = cellState;
    
    // remove sprites
    [self removeAllChildrenWithCleanup:YES];

    // add sprites
    switch (cellState) {
        case JCSFlipCellStateEmpty:
            [self addChild:_emptyCellSprite z:0];
            break;
        case JCSFlipCellStateOwnedByPlayerA:
            [self addChild:_emptyCellSprite z:0];
            [self addChild:_playerAOverlaySprite z:1];
            break;
        case JCSFlipCellStateOwnedByPlayerB:
            [self addChild:_emptyCellSprite z:0];
            [self addChild:_playerBOverlaySprite z:1];
            break;
        case JCSFlipCellStateHole:
            break;
    }
}

@end
