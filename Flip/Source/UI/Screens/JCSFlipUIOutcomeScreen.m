//
//  JCSFlipUIOutcomeScreen.m
//  Flip
//
//  Created by Christian Schuster on 13.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIOutcomeScreen.h"
#import "JCSFlipUIOutcomeScreenDelegate.h"
#import "JCSButton.h"

@implementation JCSFlipUIOutcomeScreen {
    CCLabelTTF *_outcomeLabel;
}

@synthesize status = _status;
@synthesize delegate = _delegate;
@synthesize screenEnabled = _screenEnabled;
@synthesize screenPoint = _screenPoint;

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;

        // create the rewind button
        CCMenuItem *rewindItem = [JCSButton buttonWithSize:JCSButtonSizeSmall name:@"rewind" block:^(id sender) {
            [_delegate rewindFromOutcomeScreen:self];
        }];
        rewindItem.anchorPoint = ccp(0,1);
        rewindItem.position = ccp(-winSize.width/2+10, winSize.height/2-10);

        CCMenu *menu = [CCMenu menuWithItems:rewindItem, nil];
        [self addChild:menu];
        
        _outcomeLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:48];
        _outcomeLabel.anchorPoint = ccp(0.5,0.5);
        _outcomeLabel.position = ccp(winSize.width/2.0, winSize.height/2.0);
        [self addChild:_outcomeLabel z:1];
    }
    return self;
}

- (void)setStatus:(JCSFlipGameStatus)status {
    NSString *text;
    switch (status) {
        case JCSFlipGameStatusPlayerAWon:
            text = @"Player A Wins!";
            break;
        case JCSFlipGameStatusPlayerBWon:
            text = @"Player B Wins!";
            break;
        case JCSFlipGameStatusDraw:
            text = @"Draw!";
            break;
        default:
            NSAssert(false, @"unsupported status %d", status);
    }

    _status = status;
    _outcomeLabel.string = text;
}

@end
