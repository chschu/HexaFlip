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
    
    float spriteScale;
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
        
        // scale sprites to unit width (in cell sprite coordinates)
        spriteScale = 1.0/emptyCellSpriteFrame.originalSize.width;
        _emptyCellSprite.scale = spriteScale;
        _playerAOverlaySprite.scale = spriteScale;
        _playerBOverlaySprite.scale = spriteScale;

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
        
        // make the correct child sprite visible
        _cellState = cellState;
        [self adjustChildSpriteVisibility];
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

- (void)adjustChildSpriteVisibility {
    // set visibility of child sprites
    _playerAOverlaySprite.visible = (_cellState == JCSFlipCellStateOwnedByPlayerA);
    _playerBOverlaySprite.visible = (_cellState == JCSFlipCellStateOwnedByPlayerB);
}

- (void)startFlash {
    [_emptyCellSprite stopAllActions];
    
    CCEaseInOut *tint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:192 green:192 blue:192] rate:2];
    CCEaseInOut *untint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255] rate:2];
    CCSequence *flashOnce = [CCSequence actions:tint, untint, nil];
    
    CCAction *flashAction = [CCRepeatForever actionWithAction:flashOnce];
    
    [_emptyCellSprite runAction:flashAction];
}

- (void)stopFlash {
    [_emptyCellSprite stopAllActions];
    
    CCEaseInOut *untint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255] rate:2];
    [_emptyCellSprite runAction:untint];
}

- (CCFiniteTimeAction *)createAnimationForChangeToCellState:(JCSFlipCellState)newCellState {
    // scale factor depends on wether the state changed or not
    float newScaleFactor = (_cellState == newCellState ? 0.5 : 0.0);
    
    // action: scale down
    CCScaleTo *hideAction = [CCScaleTo actionWithDuration:0.3 scale:spriteScale * newScaleFactor];
    
    // action: update cell state
    CCCallBlock *updateAction = [CCCallBlock actionWithBlock:^{
        _cellState = newCellState;
        [self adjustChildSpriteVisibility];
    }];

    // action: scale up (with elastic effect at the end)
    CCEaseElasticOut *showAction = [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:spriteScale] period:0.3];
        
    // create action sequence
    return [CCSequence actions:
            [CCSpawn actions:
             [CCTargetedAction actionWithTarget:_playerAOverlaySprite action:hideAction],
             [CCTargetedAction actionWithTarget:_playerBOverlaySprite action:[hideAction copy]],
             nil],
            updateAction,
            [CCSpawn actions:
             [CCTargetedAction actionWithTarget:_playerAOverlaySprite action:showAction],
             [CCTargetedAction actionWithTarget:_playerBOverlaySprite action:[showAction copy]],
             nil],
            nil];
}

@end
