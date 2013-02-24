//
//  JCSFlipUIBaseScreen.m
//  HexaFlip
//
//  Created by Christian Schuster on 24.02.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBaseScreen.h"

@implementation JCSFlipUIBaseScreen

@synthesize screenPoint;
@synthesize screenEnabled = _screenEnabled;

// base implementation
// override if more sophisticated handling is required
// TODO this should not be implemented here - move to subclasses
- (void)setScreenEnabled:(BOOL)screenEnabled completion:(void(^)())completion {
    _screenEnabled = screenEnabled;
    if (completion != nil) {
        completion();
    }
}

@end
