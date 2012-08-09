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
    if (self = [super initWithSpriteFrameName:@"dummy.png"]) {
        // determine sprite frames (required for proper scaling)
        CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *emptyCellSpriteFrame = [spriteFrameCache spriteFrameByName:@"cell-empty.png"];
        CCSpriteFrame *playerAOverlaySpriteFrame = [spriteFrameCache spriteFrameByName:@"cell-overlay-a.png"];
        CCSpriteFrame *playerBOverlaySpriteFrame = [spriteFrameCache spriteFrameByName:@"cell-overlay-b.png"];

        // initialize child sprites
        _emptyCellSprite = [CCSprite spriteWithSpriteFrame:emptyCellSpriteFrame];
        _playerAOverlaySprite = [CCSprite spriteWithSpriteFrame:playerAOverlaySpriteFrame];
        _playerBOverlaySprite = [CCSprite spriteWithSpriteFrame:playerBOverlaySpriteFrame];
        
        // scale sprites to unit size (in cell sprite coordinates)
        _emptyCellSprite.scaleX = 1.0/emptyCellSpriteFrame.originalSize.width;
        _emptyCellSprite.scaleY = 1.0/emptyCellSpriteFrame.originalSize.height;
        _playerAOverlaySprite.scaleX = 1.0/playerAOverlaySpriteFrame.originalSize.width;
        _playerAOverlaySprite.scaleY = 1.0/playerAOverlaySpriteFrame.originalSize.height;
        _playerBOverlaySprite.scaleX = 1.0/playerBOverlaySpriteFrame.originalSize.width;
        _playerBOverlaySprite.scaleY = 1.0/playerBOverlaySpriteFrame.originalSize.height;

        // move child sprites' centers to center of cell sprite
        _emptyCellSprite.position = ccp(0.5, 0.5);
        _playerAOverlaySprite.position = ccp(0.5, 0.5);
        _playerBOverlaySprite.position = ccp(0.5, 0.5);

        // set cell sprite content size to unit square (in parent's coordinates)
        self.contentSize = CGSizeMake(1, 1);

        _row = row;
        _column = column;
        
        // add child sprites
        [self addChild:_emptyCellSprite z:0];
        [self addChild:_playerAOverlaySprite z:1];
        [self addChild:_playerBOverlaySprite z:1];
        
        // use property access to adjust visibility
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
        // our sprite has anchor relative node coordinates from -0.5 to 0.5
        CGRect box = CGRectMake(-0.5, -0.5, 1, 1);
        // convert to anchor relative node space coordinates
        CGPoint location = [self convertTouchToNodeSpaceAR:touch];
        if (CGRectContainsPoint(box, location)) {
            // notify delegate and swallow touch if delegate tells us to
            return [_touchDelegate touchBeganWithCell:self];
        }
    }
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpaceAR:touch];
    // notify delegate about the dragging
    [_touchDelegate touchWithCell:self dragged:location ended:NO];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpaceAR:touch];
    // notify delegate about the release
    [_touchDelegate touchWithCell:self dragged:location ended:YES];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    // notify delegate about the cancellation
    [_touchDelegate touchCancelledWithCell:self];
}

- (void)setCellState:(JCSFlipCellState)cellState {
    _cellState = cellState;

    // set visibility of child sprites
    _emptyCellSprite.visible = (cellState != JCSFlipCellStateHole);
    _playerAOverlaySprite.visible = (cellState == JCSFlipCellStateOwnedByPlayerA);
    _playerBOverlaySprite.visible = (cellState == JCSFlipCellStateOwnedByPlayerB);
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
