//
//  JCSFlipUIMainMenuScreenTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 05.11.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIMainMenuScreen.h"
#import "JCSFlipGameCenterManager.h"
#import "JCSButton.h"
#import "JCSFlipUIEvents.h"

#import "OCMock.h"

@interface JCSFlipUIMainMenuScreen ()

// make selector visible to test
- (void)playerAuthenticationDidChange:(NSNotification *)notification;

@end

@interface JCSFlipUIMainMenuScreenTest : SenTestCase
@end

@implementation JCSFlipUIMainMenuScreenTest {
    JCSFlipUIMainMenuScreen *_underTest;
    id _gameCenterManagerMock;
    id _observerMock;
}

- (void)setUp {
    [super setUp];
    _underTest = [[JCSFlipUIMainMenuScreen alloc] init];
    _gameCenterManagerMock = [OCMockObject niceMockForClass:[JCSFlipGameCenterManager class]];
    [[[_gameCenterManagerMock stub] andReturn:_gameCenterManagerMock] sharedInstance];
    _observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:_observerMock name:JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME object:nil];
    [[NSNotificationCenter defaultCenter] addMockObserver:_observerMock name:JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME object:nil];
}

- (void)tearDown {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:_observerMock];
    [super tearDown];
}

- (JCSButton *)playSingleButtonForScreen:(JCSFlipUIMainMenuScreen *)screen {
    CCMenu *menu = [screen.children objectAtIndex:0];
    return [menu.children objectAtIndex:0];
}

- (JCSButton *)playMultiButtonForScreen:(JCSFlipUIMainMenuScreen *)screen {
    // TODO use tags to identify children
    CCMenu *menu = [screen.children objectAtIndex:0];
    return [menu.children objectAtIndex:1];
}

- (void)testEventTriggeredWhenPlaySingleButtonActivated {
    [[_observerMock expect] notificationWithName:JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME object:_underTest];

    [[self playSingleButtonForScreen:_underTest] activate];
    
    [_observerMock verify];
}

- (void)testPlayMultiButtonDisabledWhenGameCenterNotAuthenticated {
    [_underTest performSelector:@selector(playerAuthenticationDidChange:) withObject:nil];
    
    STAssertFalse([self playMultiButtonForScreen:_underTest].isEnabled, @"button must be disabled");
}

- (void)testPlayMultiButtonEnabledWhenGameCenterAuthenticated {
    [[[_gameCenterManagerMock stub] andReturnValue:@YES] isLocalPlayerAuthenticated];
    
    [_underTest performSelector:@selector(playerAuthenticationDidChange:) withObject:nil];
    
    STAssertTrue([self playMultiButtonForScreen:_underTest].isEnabled, @"button must be enabled");
}

- (void)testEventTriggeredWhenPlayMultiButtonActivated {
    [[[_gameCenterManagerMock stub] andReturnValue:@YES] isLocalPlayerAuthenticated];
    [[_observerMock expect] notificationWithName:JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME object:_underTest];

    [[self playMultiButtonForScreen:_underTest] activate];

    [_observerMock verify];
}

- (void)testObserverAddedWhenScreenEnabled {
    [[_gameCenterManagerMock expect] addPlayerAuthenticationObserver:_underTest selector:@selector(playerAuthenticationDidChange:)];
    
    [_underTest willActivateScreen];
    
    [_gameCenterManagerMock verify];
}

- (void)testObserverRemovedWhenScreenDisabled {
    [[_gameCenterManagerMock expect] removePlayerAuthenticationObserver:_underTest];
    
    [_underTest didDeactivateScreen];
    
    [_gameCenterManagerMock verify];
}

@end
