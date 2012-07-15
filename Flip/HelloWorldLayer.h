//
//  HelloWorldLayer.h
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *)scene;

@end
