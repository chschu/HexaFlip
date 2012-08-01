//
//  AppDelegate.m
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "JCSFlipUIGameScene.h"
#import "JCSFlipGameState.h"
#import "JCSGameHeuristic.h"
#import "JCSGameAlgorithm.h"
#import "JCSFlipGameStatePossessionSafetyHeuristic.h"
#import "JCSMinimaxGameAlgorithm.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"

#define JCS_HEX_DISTANCE(r1, c1, r2, c2) (MAX(MAX(abs((r1)-(r2)), abs((c1)-(c2))), abs((0-(r1)-(c1))-(0-(r2)-(c2)))))

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController = _navController;
@synthesize director = _director;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Create the main window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[_window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	_director = [CCDirector sharedDirector];
    
	_director.wantsFullScreenLayout = YES;
    
	_director.view = glView;
	_director.delegate = self;
    
	// 2D projection
	_director.projection = kCCDirectorProjection2D;
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if (![_director enableRetinaDisplay:YES]) {
		CCLOG(@"Retina Display Not supported");
    }
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	sharedFileUtils.enableFallbackSuffixes = YES;            // Default: NO. No fallback suffixes are going to be used
	// sharedFileUtils.iPhoneRetinaDisplaySuffix = @"-hd";		// Default on iPhone RetinaDisplay is "-hd"
	// sharedFileUtils.iPadSuffix = @"-ipad";					// Default on iPad is "ipad"
	// sharedFileUtils.iPadRetinaDisplaySuffix = @"-ipadhd";	// Default on iPad RetinaDisplay is "-ipadhd"
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    // TODO: for now, create the game state and the players here - this should be done in another scene
    
    NSInteger size = 4;
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
    
    JCSFlipGameState *state = [[JCSFlipGameState alloc] initWithSize:size status:JCSFlipGameStatusPlayerAToMove cellStateAtBlock:cellStateAtBlock];
    
    
    id<JCSGameHeuristic> heuristic = [[JCSFlipGameStatePossessionSafetyHeuristic alloc] initWithPossession:1 safety:0.7];
    id<JCSGameAlgorithm> algo = [[JCSMinimaxGameAlgorithm alloc] initWithDepth:3 heuristic:heuristic];
    
    __block JCSFlipUIGameScene *scene;
    
	// add the scene to the stack. The director will run it when it automatically when the view is displayed.
    scene = [[JCSFlipUIGameScene alloc] initWithState:state];

    // set players in scene, using the scene as move input delegate
    scene.playerA = [[JCSFlipPlayerLocal alloc] initWithName:@"dummy player name"];
    scene.playerB = [[JCSFlipPlayerAI alloc] initWithName:@"dummy player name" algorithm:algo moveInputDelegate:scene];

	[_director pushScene:scene];

	// Create a Navigation Controller with the Director
	_navController = [[UINavigationController alloc] initWithRootViewController:_director];
	_navController.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	_window.rootViewController = _navController;
	
	// make main window visible
	[_window makeKeyAndVisible];

	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
- (void)applicationWillResignActive:(UIApplication *)application {
	if (_navController.visibleViewController == _director) {
		[_director pause];
    }
}

// call got rejected
- (void)applicationDidBecomeActive:(UIApplication *)application {
	if (_navController.visibleViewController == _director) {
		[_director resume];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	if (_navController.visibleViewController == _director) {
		[_director stopAnimation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	if (_navController.visibleViewController == _director) {
		[_director startAnimation];
    }
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application {
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[CCDirector sharedDirector].nextDeltaTimeZero = YES;
}

@end
