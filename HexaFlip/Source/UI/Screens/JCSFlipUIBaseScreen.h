//
//  JCSFlipUIBaseScreen.h
//  HexaFlip
//
//  Created by Christian Schuster on 24.02.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIScreenWithPoint.h"

#import "cocos2d.h"

@interface JCSFlipUIBaseScreen : CCNode <JCSFlipUIScreenWithPoint> {
    @protected
    // variable 
    BOOL _screenEnabled;
}

@end
