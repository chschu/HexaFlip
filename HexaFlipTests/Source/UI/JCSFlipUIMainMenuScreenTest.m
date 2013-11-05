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
    id _gameCenterManagerMock;
}

- (void)setUp {
    [super setUp];
    _gameCenterManagerMock = [OCMockObject niceMockForClass:[JCSFlipGameCenterManager class]];
    [[[_gameCenterManagerMock stub] andReturn:_gameCenterManagerMock] sharedInstance];
}

- (JCSButton *)playSingleButtonForScreen:(JCSFlipUIMainMenuScreen *)screen {
    // TODO use tags to identify children
    CCMenu *menu = [screen.children objectAtIndex:0];
    return [menu.children objectAtIndex:0];
}

- (JCSButton *)playMultiButtonForScreen:(JCSFlipUIMainMenuScreen *)screen {
    // TODO use tags to identify children
    CCMenu *menu = [screen.children objectAtIndex:0];
    return [menu.children objectAtIndex:1];
}

- (void)testDelegateNotifiedWhenPlaySingleButtonActivated {
    JCSFlipUIMainMenuScreen *underTest = [[JCSFlipUIMainMenuScreen alloc] init];
    OCMockObject<JCSFlipUIMainMenuScreenDelegate> *delegateMock = [OCMockObject mockForProtocol:@protocol(JCSFlipUIMainMenuScreenDelegate)];
    underTest.delegate = delegateMock;
    [[delegateMock expect] playSingleFromMainMenuScreen:underTest];
    
    [[self playSingleButtonForScreen:underTest] activate];
    
    [delegateMock verify];
}

- (void)testAuthenticationObserverRegisteredWhenInit {
    __block id actualObserver = nil;
    [[_gameCenterManagerMock expect] addPlayerAuthenticationObserver:[OCMArg checkWithBlock:^BOOL(id obj) {
        actualObserver = obj;
        return YES;
    }] selector:@selector(playerAuthenticationDidChange:)];
    
    JCSFlipUIMainMenuScreen *underTest = [[JCSFlipUIMainMenuScreen alloc] init];

    [_gameCenterManagerMock verify];
    STAssertEqualObjects(actualObserver, underTest, @"observer must be the tested object");
}

- (void)testPlayMultiButtonDisabledWhenGameCenterNotAuthenticated {
    JCSFlipUIMainMenuScreen *underTest = [[JCSFlipUIMainMenuScreen alloc] init];
    
    [underTest performSelector:@selector(playerAuthenticationDidChange:) withObject:nil];
    
    STAssertFalse([self playMultiButtonForScreen:underTest].isEnabled, @"button must be disabled");
}

- (void)testPlayMultiButtonEnabledWhenGameCenterAuthenticated {
    [[[_gameCenterManagerMock stub] andReturnValue:@YES] isLocalPlayerAuthenticated];
    JCSFlipUIMainMenuScreen *underTest = [[JCSFlipUIMainMenuScreen alloc] init];
    
    [underTest performSelector:@selector(playerAuthenticationDidChange:) withObject:nil];
    
    STAssertTrue([self playMultiButtonForScreen:underTest].isEnabled, @"button must be enabled");
}

- (void)testDelegateNotifiedWhenPlayMultiButtonActivated {
    [[[_gameCenterManagerMock stub] andReturnValue:@YES] isLocalPlayerAuthenticated];
    JCSFlipUIMainMenuScreen *underTest = [[JCSFlipUIMainMenuScreen alloc] init];
    OCMockObject<JCSFlipUIMainMenuScreenDelegate> *delegateMock = [OCMockObject mockForProtocol:@protocol(JCSFlipUIMainMenuScreenDelegate)];
    underTest.delegate = delegateMock;
    [[delegateMock expect] playMultiFromMainMenuScreen:underTest];

    [[self playMultiButtonForScreen:underTest] activate];
    
    [delegateMock verify];
}

@end
