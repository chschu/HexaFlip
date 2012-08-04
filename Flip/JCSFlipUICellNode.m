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
    
    CCAction *_flashAction;
}

@synthesize cellState = _cellState;
@synthesize row = _row;
@synthesize column = _column;
@synthesize touchDelegate = _touchDelegate;

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
    // we don't consider touches on holes
    if (_cellState != JCSFlipCellStateHole) {
        // our sprite has node coordinates from -0.5 to 0.5
        CGRect box = CGRectMake(-0.5, -0.5, 1, 1);
        CGPoint location = [self convertTouchToNodeSpace:touch];
        if (CGRectContainsPoint(box, location)) {
            // notify delegate and swallow touch if delegate tells us to
            return [_touchDelegate touchBeganWithCell:self];
        }
    }
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace:touch];
    // notify delegate about the dragging
    [_touchDelegate touchWithCell:self dragged:location ended:NO];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace:touch];
    // notify delegate about the release
    [_touchDelegate touchWithCell:self dragged:location ended:YES];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    // notify delegate about the cancellation
    [_touchDelegate touchCancelledWithCell:self];
}

- (void)setCellState:(JCSFlipCellState)cellState {
    _cellState = cellState;
    
    // remove sprites
    [self removeAllChildrenWithCleanup:NO];
    
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

- (void)startFlash {
    if (_flashAction != nil) {
        [_emptyCellSprite stopAction:_flashAction];
    }
        
    CCTintTo *tint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:192 green:192 blue:192] rate:2];
    CCTintTo *untint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255] rate:2];
    CCSequence *flashOnce = [CCSequence actions:tint, untint, nil];
    
    _flashAction = [CCRepeatForever actionWithAction:flashOnce];
    
    [_emptyCellSprite runAction:_flashAction];
}

- (void)stopFlash {
    if (_flashAction != nil) {
        [_emptyCellSprite stopAction:_flashAction];
        CCTintTo *untint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255] rate:2];
        CCCallBlock *reset = [CCCallBlock actionWithBlock:^{
            self.cellState = _cellState;
        }];
        CCSequence *unflash = [CCSequence actionOne:untint two:reset];
        [_emptyCellSprite runAction:unflash];
        _flashAction = nil;
    }
}

@end
