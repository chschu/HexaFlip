//
//  JCSFlipUIGameOverLayer.h
//  Flip
//
//  Created by Christian Schuster on 02.08.12.
//  Copyright 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameStatus.h"

#import "cocos2d.h"

@interface JCSFlipUIGameOverLayer : CCLayerColor <CCTargetedTouchDelegate>

// alloc and init a layer with the given status, which must be one of the "Over" statuses
+ (CCLayer *)layerWithText:(NSString *)text;

@end
