//
//  AppDelegate.m
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "JCSFlipUIScene.h"

// extend CCDirector to support Auto-Rotation with iOS 6
@interface CCDirectorIOS (iOS6)
@end

@implementation CCDirectorIOS (iOS6)

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end

@implementation AppDelegate {
    BOOL _wasAnimating;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	CCDirector *director = [CCDirector sharedDirector];
    
	director.wantsFullScreenLayout = YES;
    
	// 2D projection
	director.projection = kCCDirectorProjection2D;
    
	// create the main window
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // create the OpenGL view that cocos2d will render to.
    CCGLView *glView = [CCGLView viewWithFrame:_window.bounds
                                   pixelFormat:kEAGLColorFormatRGBA8
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];
    
    // assign the view to the director.
    director.view = glView;
    
    // enables high-resolution mode (retina display) if supported
    // must be done after the view has been set on the director
    if (![director enableRetinaDisplay:YES]) {
        CCLOG(@"Retina Display not supported");
    }
    
	// Display FSP and SPF
	[director setDisplayStats:YES];
    
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
    
	// for rotation and other messages
	[director setDelegate:self];
    
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
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director pushScene:[JCSFlipUIScene node]];
    	
	// set the director as the root view controller
	[_window setRootViewController:director];

	// make main window visible
	[_window makeKeyAndVisible];
	
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// enter inactive state (incoming call, application about to enter background)
- (void)applicationWillResignActive:(UIApplication *)application {
    [[CCDirector sharedDirector] pause];
}

// enter active state (incoming call rejected, application about to enter foreground)
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[CCDirector sharedDirector] resume];
}

// stop animations when entering background
- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([CCDirector sharedDirector].isAnimating) {
        _wasAnimating = YES;
        [[CCDirector sharedDirector] stopAnimation];
    } else {
        _wasAnimating = NO;
    }
}

// start animations when entering foreground
- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (_wasAnimating) {
        [[CCDirector sharedDirector] startAnimation];
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
