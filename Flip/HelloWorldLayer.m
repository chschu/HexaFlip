//
//  HelloWorldLayer.m
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// create and return an initialized instance of the scene
+ (CCScene *)scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

// prepare display of the scene
- (void)onEnter  {
    [super onEnter];
    
    // create and initialize a Label
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
    
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
	
    // position the label on the center of the screen
    label.position =  ccp(size.width/2 , size.height/2);
    
    // add the label as a child to this Layer
    [self addChild: label];
    
    //
    // Leaderboards and Achievements
    //
    
    // Default font size will be 28 points.
    [CCMenuItemFont setFontSize:28];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    // Achievement Menu Item using blocks
    void(^blockAchievement)(id sender) = ^(id sender) {
        GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
        achivementViewController.achievementDelegate = self;
        [app.navController presentModalViewController:achivementViewController animated:YES];
    };
    CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:blockAchievement];
    
    // Leaderboard Menu Item using blocks
    void(^blockLeaderboard)(id sender) = ^(id sender) {
        GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
        leaderboardViewController.leaderboardDelegate = self;
        [app.navController presentModalViewController:leaderboardViewController animated:YES];
    };
    CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:blockLeaderboard];
    
    CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
    
    [menu alignItemsHorizontallyWithPadding:20];
    menu.position = ccp(size.width/2, size.height/2 - 50);
    
    // Add the menu to the layer
    [self addChild:menu];
}

#pragma mark GameKit delegate methods

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[app.navController dismissModalViewControllerAnimated:YES];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[app.navController dismissModalViewControllerAnimated:YES];
}
@end
