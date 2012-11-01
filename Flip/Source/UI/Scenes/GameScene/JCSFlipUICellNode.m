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
    CCSprite *_playerAOverlaySprite;
    CCSprite *_playerBOverlaySprite;
}

@synthesize cellState = _cellState;
@synthesize row = _row;
@synthesize column = _column;
@synthesize touchDelegate = _touchDelegate;

+ (id)nodeWithRow:(NSInteger)row column:(NSInteger)column cellState:(JCSFlipCellState)cellState {
    return [[self alloc] initWithRow:row column:column cellState:cellState];
}

- (id)initWithRow:(NSInteger)row column:(NSInteger)column cellState:(JCSFlipCellState)cellState {
    NSAssert(cellState != JCSFlipCellStateHole, @"cell cannot be initialized to display a hole");

    if (self = [super initWithSpriteFrameName:@"cell-empty.png"]) {
        // initialize child sprites
        _playerAOverlaySprite = [CCSprite spriteWithSpriteFrameName:@"cell-overlay-a.png"];
        _playerBOverlaySprite = [CCSprite spriteWithSpriteFrameName:@"cell-overlay-b.png"];
        
        // move child sprites' to center of cell sprite
        CGPoint center = ccp(self.contentSize.width/2.0,self.contentSize.height/2.0);
        _playerAOverlaySprite.position = center;
        _playerBOverlaySprite.position = center;
        
        _row = row;
        _column = column;
        
        // add child sprites
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
    // determine content rectangle in anchor relative node coordinates
    float w = self.contentSize.width;
    float h = self.contentSize.height;
    CGRect box = CGRectMake(-w/2.0, -h/2.0, w, h);
    // convert to anchor relative node space coordinates
    CGPoint location = [self convertTouchToNodeSpaceAR:touch];
    if (CGRectContainsPoint(box, location)) {
        // notify delegate and swallow touch if delegate tells us to
        return [_touchDelegate touchBeganWithCell:self];
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
    [self stopAllActions];
    
    CCEaseInOut *tint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:192 green:192 blue:192] rate:2];
    CCEaseInOut *untint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255] rate:2];
    CCSequence *flashOnce = [CCSequence actions:tint, untint, nil];
    
    CCAction *flashAction = [CCRepeatForever actionWithAction:flashOnce];
    
    [self runAction:flashAction];
}

- (void)stopFlash {
    [self stopAllActions];
    
    CCEaseInOut *untint = [CCEaseInOut actionWithAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255] rate:2];
    [self runAction:untint];
}

- (CCFiniteTimeAction *)createAnimationForChangeToCellState:(JCSFlipCellState)newCellState {
    NSAssert(newCellState != JCSFlipCellStateHole, @"cell cannot be animated to display a hole");
    
    // scale factor depends on wether the state changed or not
    float newScale = (_cellState == newCellState ? 0.5 : 0.0);
    
    // action: scale down
    CCScaleTo *hideAction = [CCScaleTo actionWithDuration:0.3 scale:newScale];
    
    // action: update cell state
    CCCallBlock *updateAction = [CCCallBlock actionWithBlock:^{
        _cellState = newCellState;
        [self adjustChildSpriteVisibility];
    }];
    
    // action: scale up (with elastic effect at the end)
    CCEaseElasticOut *showAction = [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:1.0] period:0.3];
    
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
