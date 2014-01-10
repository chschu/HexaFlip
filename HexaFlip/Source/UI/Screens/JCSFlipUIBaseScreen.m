//
//  JCSFlipUIBaseScreen.m
//  HexaFlip
//
//  Created by Christian Schuster on 24.02.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBaseScreen.h"

@implementation JCSFlipUIBaseScreen

- (void)visit {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // determine screen's bounds in world coordinates
    CGPoint p1 = [self convertToWorldSpace:ccp(0,0)];
    CGPoint p2 = [self convertToWorldSpace:ccp(winSize.width,winSize.height)];
    CGRect screenRectInWorldSpace = CGRectMake(p1.x,p1.y,p2.x-p1.x,p2.y-p1.y);
    
    // render this screen only if its screen rectangle intersects with the visible world rectangle
    CGRect visibleRectInWorldSpace = CGRectMake(0, 0, winSize.width, winSize.height);
    CGRect intersection = CGRectIntersection(visibleRectInWorldSpace, screenRectInWorldSpace);
    if (!CGRectIsEmpty(intersection)) {
        [super visit];
    }
}

@end
