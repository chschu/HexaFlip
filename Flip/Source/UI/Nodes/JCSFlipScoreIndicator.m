//
//  JCSFlipScoreIndicator.m
//  HexaFlip
//
//  Created by Christian Schuster on 02.12.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipScoreIndicator.h"
#import "JCSFlipUIConstants.h"

@implementation JCSFlipScoreIndicator {
    NSInteger _scoreA;
    NSInteger _scoreB;
    
    CCSprite *_spritePlayerA;
    CCSprite *_spritePlayerB;
    CCSprite *_spriteOverlay;
    CCSprite *_spriteMask;
    
    // texture for off-screen rendering of the pipe
    CCRenderTexture *_pipeTexture;
}

- (id)init {
    if (self = [super init]) {
        _scoreA = 0;
        _scoreB = 0;
        
        // node coordinate origin is at the bottom left

        // create sprites
        _spritePlayerA = [CCSprite spriteWithSpriteFrameName:@"score-player-a.png"];
        _spritePlayerB = [CCSprite spriteWithSpriteFrameName:@"score-player-b.png"];
        _spriteOverlay = [CCSprite spriteWithSpriteFrameName:@"score-overlay.png"];
        _spriteMask = [CCSprite spriteWithSpriteFrameName:@"score-mask.png"];

        CGSize size = _spriteMask.contentSize;
        CGFloat width = size.width;
        CGFloat height = size.height;
        
        // create the off-screen texture
        _pipeTexture = [CCRenderTexture renderTextureWithWidth:width height:height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];

        // the player b sprite should be fixed at the top
        _spritePlayerB.anchorPoint = ccp(0,1);
        _spritePlayerB.position = ccp(0,height);
        
        // the remaining sprites remain unscaled and are placed at the origin of the off-screen texture
        _spritePlayerA.anchorPoint = ccp(0,0);
        _spritePlayerA.position = ccp(0,0);
        _spriteOverlay.anchorPoint = ccp(0,0);
        _spriteOverlay.position = ccp(0,0);
        _spriteMask.anchorPoint = ccp(0,0);
        _spriteMask.position = ccp(0,0);

        // the off-screen texture is centered in the node
        _pipeTexture.sprite.anchorPoint = ccp(0.5,0.5);
        _pipeTexture.sprite.position = ccp(width/2.0,height/2.0);

        // set special blend functions
        _spriteMask.blendFunc = (ccBlendFunc) { GL_ZERO, GL_SRC_ALPHA }; // post-render mask

        // add the sprites and the texture as children to make actions work properly
        [self addChild:_pipeTexture];
        [self addChild:_spritePlayerA];
        [self addChild:_spritePlayerB];
        [self addChild:_spriteMask];
        [self addChild:_spriteOverlay];
        
        // set content size for correct positioning
        self.contentSize = size;
        
        // initialize (without animation)
        [self updateAnimated:NO];
    }
    return self;
}

- (void)updateAnimated:(BOOL)animated {
    CGFloat targetScaleB;
    
    NSInteger scoreSum = _scoreA + _scoreB;
    if (scoreSum > 0) {
        targetScaleB = 1.0*_scoreB/scoreSum;
    } else {
        targetScaleB = 0.5;
    }

    if (animated) {
        CCScaleTo *scaleB = [CCScaleTo actionWithDuration:JCS_FLIP_UI_SCORE_INDICATOR_ANIMATION_DURATION scaleX:1 scaleY:targetScaleB];
        [_spritePlayerB runAction:[CCEaseExponentialOut actionWithAction:scaleB]];
    } else {
        _spritePlayerB.scaleY = targetScaleB;
    }
}

// overridden to perform custom rendering
- (void)visit {
	// quick return if not visible
	if (!visible_) {
		return;
    }
    
    // start rendering into the off-screen texture
    kmGLPushMatrix();
    kmGLLoadIdentity();
    [_pipeTexture begin];
    
    // draw player A's pipe
    [_spritePlayerA visit];

    // draw player B's pipe
    [_spritePlayerB visit];
    
    // draw the shadow overlay
    [_spriteOverlay visit];

    // draw the pipe mask
    // with the given blend mode, this creates the transparent areas of the pipe
    [_spriteMask visit];
    
    // stop rendering into the off-screen texture
    [_pipeTexture end];
    kmGLPopMatrix();
    
    // remember the old matrix
	kmGLPushMatrix();
    
    // apply our transformation
	[self transform];
    
    // draw the texture
    [_pipeTexture.sprite visit];
    
    // restore the matrix
	kmGLPopMatrix();
}

- (void)setScoreA:(NSInteger)scoreA scoreB:(NSInteger)scoreB animated:(BOOL)animated {
    NSAssert(scoreA >= 0 && scoreB >= 0, @"scores must be non-negative");
    _scoreA = scoreA;
    _scoreB = scoreB;
    [self updateAnimated:animated];
}

@end
