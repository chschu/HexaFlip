//
//  JCSFlipGameController.m
//  Flip
//
//  Created by Christian Schuster on 30.08.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipGameController.h"
#import "JCSFlipUIGameScene.h"

@implementation JCSFlipGameController

@synthesize playerA = _playerA;
@synthesize playerB = _playerB;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // both players must have been set
    NSAssert(_playerA != nil, @"playerA must be non-nil");
    NSAssert(_playerB != nil, @"playerB must be non-nil");
    
    // hide the navigation bar when the view appears
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    CCDirector *director = [CCDirector sharedDirector];
    
    // Set the view controller as the director's delegate, so we can respond to certain events.
    director.delegate = self;
    
    // add the director as a child view controller of this view controller.
    [self addChildViewController:director];
    
    // add the director's OpenGL view as a subview so we can see it.
    [self.view addSubview:director.view];
    [self.view sendSubviewToBack:director.view];
    
    // finish up our view controller containment responsibilities.
    [director didMoveToParentViewController:self];
    
    JCSFlipGameState *state = [self createBoardOfSize:5];
    JCSFlipUIGameScene *scene = [JCSFlipUIGameScene sceneWithState:state playerA:_playerA playerB:_playerB exitBlock:^(id sender) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    // run whatever scene we'd like to run here.
    if (director.runningScene) {
        [director replaceScene:scene];
    } else {
        [director pushScene:scene];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // show the navigation bar when the view disappears
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) (MAX(MAX(abs((r1)-(r2)), abs((c1)-(c2))), abs((0-(r1)-(c1))-(0-(r2)-(c2)))))

- (JCSFlipGameState *)createBoardOfSize:(NSInteger)size {
    JCSFlipCellState(^cellStateAtBlock)(NSInteger, NSInteger) = ^JCSFlipCellState(NSInteger row, NSInteger column) {
        NSInteger distanceFromOrigin = JCS_HEX_DISTANCE(row, column, 0, 0);
        if (distanceFromOrigin == 0 || distanceFromOrigin > size-1) {
            return JCSFlipCellStateHole;
        } else if (distanceFromOrigin == 1) {
            if (row + 2*column < 0) {
                return JCSFlipCellStateOwnedByPlayerA;
            } else {
                return JCSFlipCellStateOwnedByPlayerB;
            }
        } else {
            return JCSFlipCellStateEmpty;
        }
    };
    
    return [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
}

@end
