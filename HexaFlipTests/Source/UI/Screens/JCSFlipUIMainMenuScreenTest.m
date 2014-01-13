//
//  JCSFlipUIMainMenuScreenTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 05.11.13.
//  Copyright (c) 2013 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIMainMenuScreen.h"
#import "JCSFlipUIMainMenuScreenDelegate.h"
#import "JCSFlipGameCenterManager.h"
#import "JCSButton.h"

#import "OCMock.h"

@interface JCSFlipUIMainMenuScreenTest : SenTestCase
@end

@implementation JCSFlipUIMainMenuScreenTest {
    JCSFlipUIMainMenuScreen *_underTest;
    id _gameCenterManagerMock;
}

- (void)setUp {
    [super setUp];
    _underTest = [[JCSFlipUIMainMenuScreen alloc] init];
    _gameCenterManagerMock = [OCMockObject niceMockForClass:[JCSFlipGameCenterManager class]];
    [[[_gameCenterManagerMock stub] andReturn:_gameCenterManagerMock] sharedInstance];
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

- (void)testDelegateNotifiedWhenPlaySingleButtonActivated {
    OCMockObject<JCSFlipUIMainMenuScreenDelegate> *delegateMock = [OCMockObject mockForProtocol:@protocol(JCSFlipUIMainMenuScreenDelegate)];
    _underTest.delegate = delegateMock;
    [[delegateMock expect] playSingleFromMainMenuScreen:_underTest];
    
    [[self playSingleButtonForScreen:_underTest] activate];
    
    [delegateMock verify];
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

- (void)testDelegateNotifiedWhenPlayMultiButtonActivated {
    [[[_gameCenterManagerMock stub] andReturnValue:@YES] isLocalPlayerAuthenticated];
    OCMockObject<JCSFlipUIMainMenuScreenDelegate> *delegateMock = [OCMockObject mockForProtocol:@protocol(JCSFlipUIMainMenuScreenDelegate)];
    _underTest.delegate = delegateMock;
    [[delegateMock expect] playMultiFromMainMenuScreen:_underTest];

    [[self playMultiButtonForScreen:_underTest] activate];
    
    [delegateMock verify];
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
