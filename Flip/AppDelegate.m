//
//  AppDelegate.m
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "JCSFlipUIMainMenuScene.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController = _navController;
@synthesize director = _director;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Create the main window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// Create an CCGLView with a RGBA8 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[_window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0
							preserveBackbuffer:YES
									sharegroup:nil
								 multiSampling:YES
							   numberOfSamples:3];
    
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

    // initialize texture atlas
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture-atlas.plist"];

	// add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[_director runWithScene:[JCSFlipUIMainMenuScene scene]];

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
