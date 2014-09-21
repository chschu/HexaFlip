//
//  JCSFlipUIPlayerMenuScreenTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 09.02.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

#import "JCSButton.h"
#import "JCSRadioMenu.h"
#import "JCSFlipUIPlayerMenuScreen.h"
#import "JCSFlipUIEvents.h"
#import "JCSFlipPlayerLocal.h"
#import "JCSFlipPlayerAI.h"
#import "JCSFlipGameState.h"

#import "OCMock.h"

@interface JCSFlipUIPlayerMenuScreenTest : XCTestCase
@end

@implementation JCSFlipUIPlayerMenuScreenTest {
    JCSFlipUIPlayerMenuScreen *_underTest;
    id _observerMock;
    id _gameStateMock;
}

- (void)setUp {
    [super setUp];
    _underTest = [[JCSFlipUIPlayerMenuScreen alloc] init];
    _observerMock = [OCMockObject observerMock];
    _gameStateMock = [OCMockObject mockForClass:[JCSFlipGameState class]];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addMockObserver:_observerMock name:JCS_FLIP_UI_BACK_EVENT_NAME object:nil];
    [nc addMockObserver:_observerMock name:JCS_FLIP_UI_PREPARE_GAME_EVENT_NAME object:nil];
    [nc addMockObserver:_observerMock name:JCS_FLIP_UI_PLAY_GAME_EVENT_NAME object:nil];
}

- (void)tearDown {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:_observerMock];
    [super tearDown];
}

- (JCSButton *)backButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    CCMenu *menu = [screen.children objectAtIndex:0];
    return [menu.children objectAtIndex:0];
}

- (JCSButton *)playButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    CCMenu *menu = [screen.children objectAtIndex:0];
    return [menu.children objectAtIndex:1];
}

- (JCSButton *)playerALocalButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerA = [screen.children objectAtIndex:1];
    return [radioPlayerA.children objectAtIndex:0];
}

- (JCSButton *)playerAAIEasyButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerA = [screen.children objectAtIndex:1];
    return [radioPlayerA.children objectAtIndex:1];
}

- (JCSButton *)playerAAIMediumButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerA = [screen.children objectAtIndex:1];
    return [radioPlayerA.children objectAtIndex:2];
}

- (JCSButton *)playerAAIHardButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerA = [screen.children objectAtIndex:1];
    return [radioPlayerA.children objectAtIndex:3];
}

- (JCSButton *)playerBLocalButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerB = [screen.children objectAtIndex:2];
    return [radioPlayerB.children objectAtIndex:0];
}

- (JCSButton *)playerBAIEasyButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerB = [screen.children objectAtIndex:2];
    return [radioPlayerB.children objectAtIndex:1];
}

- (JCSButton *)playerBAIMediumButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerB = [screen.children objectAtIndex:2];
    return [radioPlayerB.children objectAtIndex:2];
}

- (JCSButton *)playerBAIHardButtonForScreen:(JCSFlipUIPlayerMenuScreen *)screen {
    JCSRadioMenu *radioPlayerB = [screen.children objectAtIndex:2];
    return [radioPlayerB.children objectAtIndex:3];
}

- (void)testEventTriggeredWhenBackButtonActivated {
    [[_observerMock expect] notificationWithName:JCS_FLIP_UI_BACK_EVENT_NAME object:_underTest];
    
    [[self backButtonForScreen:_underTest] activate];
    
    [_observerMock verify];
}

- (void)checkEventsWhenActivatingButton:(JCSButton *)button checkPlayerDescriptionsUsingBlock:(void(^)(NSString *playerADescription, NSString *playerBDescription))block {
    __block NSDictionary *capturedUserInfo;
    [[_observerMock expect] notificationWithName:JCS_FLIP_UI_PREPARE_GAME_EVENT_NAME object:_underTest userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        capturedUserInfo = userInfo;
        return YES;
    }]];
    [[_observerMock expect] notificationWithName:JCS_FLIP_UI_PLAY_GAME_EVENT_NAME object:_underTest];
    
    [[[_gameStateMock expect] andReturn:_gameStateMock] alloc];
    (void) [[[_gameStateMock expect] andReturn:_gameStateMock] initWithSize:5 playerToMove:JCSFlipPlayerSideA];
    
    [button activate];
    [[self playButtonForScreen:_underTest] activate];
    
    [_observerMock verify];
    
    XCTAssertEqual(capturedUserInfo.count, 1u);
    JCSFlipUIPrepareGameEventData *capturedEventData = capturedUserInfo[capturedUserInfo.keyEnumerator.nextObject];
    XCTAssertNotNil(capturedEventData);
    XCTAssertEqual(capturedEventData.gameState, _gameStateMock);
    XCTAssertNil(capturedEventData.match);
    XCTAssertFalse(capturedEventData.animateLastMove);
    XCTAssertFalse(capturedEventData.moveInputDisabled);
    block(capturedEventData.playerA.description, capturedEventData.playerB.description);
}

static NSString *descriptionForLocalPlayer = @"(Local Player)";
static NSString *descriptionForAIEasyPlayer = @"(AI player; (NegaScout Algorithm; (Transposition Table; Size 1000000); (Possession Heuristic); Depth 1))";
static NSString *descriptionForAIMediumPlayer = @"(AI player; (NegaScout Algorithm; (Transposition Table; Size 1000000); (Possession Heuristic); Depth 4))";
static NSString *descriptionForAIHardPlayer = @"(AI player; (NegaScout Algorithm; (Transposition Table; Size 1000000); (Possession Heuristic); Depth 6))";

- (void)testEventsWhenPlayerTypesChangedAndPlayButtonActivated {
    [self checkEventsWhenActivatingButton:nil checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForLocalPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIMediumPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerAAIEasyButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIEasyPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIMediumPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerBLocalButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIEasyPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForLocalPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerAAIHardButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIHardPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForLocalPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerBAIMediumButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIHardPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIMediumPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerAAIMediumButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIMediumPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIMediumPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerBAIEasyButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIMediumPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIEasyPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerBAIHardButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForAIMediumPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIHardPlayer);
    }];
    [self checkEventsWhenActivatingButton:[self playerALocalButtonForScreen:_underTest] checkPlayerDescriptionsUsingBlock:^(NSString *playerADescription, NSString *playerBDescription) {
        XCTAssertEqualObjects(playerADescription, descriptionForLocalPlayer);
        XCTAssertEqualObjects(playerBDescription, descriptionForAIHardPlayer);
    }];
    
}

@end
