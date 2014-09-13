//
//  JCSFlipUIBaseScreenTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 14.01.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

#import "JCSFlipUIBaseScreen.h"

#import "OCMock.h"

#import <objc/runtime.h>

static BOOL swizzledVisitInvoked;

// category to detect invocation of [super visit]
@interface JCSFlipUIBaseScreen (Test)

- (void)swizzledVisit;

@end

@implementation JCSFlipUIBaseScreen (Test)

- (void)swizzledVisit {
    swizzledVisitInvoked = YES;
}

@end

@interface JCSFlipUIBaseScreenTest : XCTestCase
@end

@implementation JCSFlipUIBaseScreenTest {
    JCSFlipUIBaseScreen *_underTest;
    id _directorMock;
}

- (void)setUp {
    [super setUp];
    _underTest = [[JCSFlipUIBaseScreen alloc] init];

    _directorMock = [OCMockObject niceMockForClass:[CCDirector class]];
    [[[_directorMock stub] andReturn:_directorMock] sharedDirector];
}

// check if [super visit] is invoked, depending on the screen size, and the bounds of the node in world space
- (BOOL)superVisitInvokedWithScreenWidth:(NSInteger)screenWidth screenHeight:(NSInteger)screenHeight left:(NSInteger)left bottom:(NSInteger)bottom right:(NSInteger)right top:(NSInteger)top {

    [[[_directorMock stub] andReturnValue:[NSValue valueWithCGSize:CGSizeMake(screenWidth,screenHeight)]] winSize];
    
    id partialMockUnderTest = [OCMockObject partialMockForObject:_underTest];
    [[[partialMockUnderTest stub] andReturnValue:[NSValue valueWithCGPoint:ccp(left,bottom)]] convertToWorldSpace:ccp(0,0)];
    [[[partialMockUnderTest stub] andReturnValue:[NSValue valueWithCGPoint:ccp(right,top)]] convertToWorldSpace:ccp(screenWidth,screenHeight)];
    
    // swizzle [CCNode visit] and [JCSFlipUIBaseScreen swizzledVisid] (from Test category)
    Method original = class_getInstanceMethod(_underTest.superclass, @selector(visit));
    Method swizzled = class_getInstanceMethod(_underTest.class, @selector(swizzledVisit));
    method_exchangeImplementations(original, swizzled);
    @try {
        swizzledVisitInvoked = NO;
        [partialMockUnderTest visit];
        return swizzledVisitInvoked;
    } @finally {
        // swizzle back
        method_exchangeImplementations(original, swizzled);
    }
}

- (void)testSuperVisitInvokedWhenVisible {
    XCTAssertTrue([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:19 bottom:9 right:30 top:30]);
    XCTAssertTrue([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:19 bottom:-30 right:30 top:1]);
    XCTAssertTrue([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:-30 bottom:-30 right:1 top:1]);
    XCTAssertTrue([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:-30 bottom:9 right:1 top:30]);
}

- (void)testSuperVisitNotInvokedWhenNotVisible {
    XCTAssertFalse([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:19 bottom:10 right:30 top:30]);
    XCTAssertFalse([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:20 bottom:9 right:30 top:30]);
    XCTAssertFalse([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:-30 bottom:-30 right:1 top:0]);
    XCTAssertFalse([self superVisitInvokedWithScreenWidth:20 screenHeight:10 left:-30 bottom:-30 right:0 top:1]);
}

@end
