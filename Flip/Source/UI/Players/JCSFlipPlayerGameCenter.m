//
//  JCSFlipPlayerGameCenter.m
//  Flip
//
//  Created by Christian Schuster on 12.12.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipPlayerGameCenter.h"
#import "cocos2d.h"

@implementation JCSFlipPlayerGameCenter

@synthesize name = _name;
@synthesize moveInputDelegate = _moveInputDelegate;

+ (id)player {
    return [[self alloc] init];
}

- (id)init {
    if (self = [super init]) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            if (error == nil) {
                GKMatchRequest *request = [GKMatchRequest new];
                request.minPlayers = 2;
                request.maxPlayers = 2;
                
                GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
                mmvc.matchmakerDelegate = self;
                [[CCDirector sharedDirector] presentModalViewController:mmvc animated:YES];
            } else {
                // TODO: handle error
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    return self;
}

- (BOOL)localControls {
    return NO;
}

- (void)tellMakeMove:(JCSFlipGameState *)state {
    // TODO: send state to GC
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [viewController dismissModalViewControllerAnimated:YES];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    // TODO: handle error
    NSLog(@"%@", error.localizedDescription);
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
    [viewController dismissModalViewControllerAnimated:YES];
    // TODO: start game
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
