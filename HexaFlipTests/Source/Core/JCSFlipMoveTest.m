//
//  JCSFlipMoveTest.m
//  HexaFlip
//
//  Created by Christian Schuster on 18.07.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMove.h"
#import "JCSFlipMoveInputDelegate.h"

#import "OCMock.h"

#import <objc/runtime.h>

// category with methods to track blocks that are scheduled during move input
@implementation JCSFlipMove (BlockCollectingTest)

// dictionary for collecting and sorting blocks
// key: block (dispatch_block_t), value: delay (NSNumber *)
static NSMutableDictionary *_delayForBlock;

- (void)clearCollectedBlocks {
    _delayForBlock = [NSMutableDictionary dictionary];
}

// will be swizzled with invokeOnMainQueueAfterDelay:block:
- (void)collectWithDelay:(double)seconds block:(dispatch_block_t)block {
    [_delayForBlock setObject:@(seconds) forKey:block];
}

- (void)invokeCollectedBlocks {
    NSArray *blocksSortedByDelay = [_delayForBlock keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *delay1, NSNumber *delay2) {
        return [delay1 compare:delay2];
    }];
    for (dispatch_block_t block in blocksSortedByDelay) {
        block();
    }
}

@end

@interface  JCSFlipMove ()

// make selector visible to test
- (void)dispatchToMainQueueAfterDelay:(double)seconds block:(dispatch_block_t)block;

@end

@interface JCSFlipMoveTest : XCTestCase
@end

@implementation JCSFlipMoveTest {
    // each entry is an NSArray containing a NSNumber (delay, index 0) and a dispatch_block_t (block, index 1)
    NSMutableArray *_blockInfo;
}

- (void)testInitMove {
    JCSFlipMove *move = [[JCSFlipMove alloc] initWithStartRow:1 startColumn:4 direction:JCSHexDirectionNE];
    
    XCTAssertFalse(move.skip);
    XCTAssertEqual(move.startRow, 1);
    XCTAssertEqual(move.startColumn, 4);
    XCTAssertEqual(move.direction, JCSHexDirectionNE);
}

- (void)testInitSkip {
    JCSFlipMove *move = [[JCSFlipMove alloc] init];
    
    XCTAssertTrue(move.skip);
    XCTAssertThrows([move startRow]);
    XCTAssertThrows([move startColumn]);
    XCTAssertThrows([move direction]);
}

- (void)testMutable {
    JCSFlipMove *move = [[JCSFlipMove alloc] init];
    
    move.skip = NO;
    move.startRow = 1;
    move.startColumn = 2;
    move.direction = JCSHexDirectionNW;
    
    XCTAssertFalse(move.skip);
    XCTAssertEqual(move.startRow, 1);
    XCTAssertEqual(move.startColumn, 2);
    XCTAssertEqual(move.direction, JCSHexDirectionNW);
}

- (void)testCopy {
    JCSFlipMove *move = [[JCSFlipMove alloc] initWithStartRow:32 startColumn:12 direction:JCSHexDirectionE];
    JCSFlipMove *copy = [move copy];
    
    XCTAssertFalse(move == copy);
    XCTAssertTrue([copy class] == [JCSFlipMove class]);
    XCTAssertEqual(move.skip, copy.skip);
    XCTAssertEqual(move.startRow, copy.startRow);
    XCTAssertEqual(move.startColumn, copy.startColumn);
    XCTAssertEqual(move.direction, copy.direction);
}

- (void)doTestPerformInputWithMove:(JCSFlipMove *)move {
    OCMockObject<JCSFlipMoveInputDelegate> *delegateMock = [OCMockObject mockForProtocol:@protocol(JCSFlipMoveInputDelegate)];
    [delegateMock setExpectationOrderMatters:YES];
    if (!move.skip) {
        [[[delegateMock expect] andReturnValue:@(YES)] inputSelectedStartRow:move.startRow startColumn:move.startColumn];
        [[delegateMock expect] inputSelectedDirection:move.direction startRow:move.startRow startColumn:move.startColumn];
        [[delegateMock expect] inputClearedDirection:move.direction startRow:move.startRow startColumn:move.startColumn];
        [[delegateMock expect] inputClearedStartRow:move.startRow startColumn:move.startColumn];
    }
    [[delegateMock expect] inputConfirmedWithMove:move];
    
    // swizzle delayed invocation to cut down test time and avoid using the main queue
    Method original = class_getInstanceMethod(move.class, @selector(dispatchToMainQueueAfterDelay:block:));
    Method swizzled = class_getInstanceMethod(move.class, @selector(collectWithDelay:block:));
    method_exchangeImplementations(original, swizzled);
    @try {
        // clear collected blocks
        [move clearCollectedBlocks];
        
        // invoke the method to be tested, collecting any blocks that are scheduled
        [move performInputWithMoveInputDelegate:delegateMock];
        
        // invoke collected blocks in correct order
        [move invokeCollectedBlocks];
        
        [delegateMock verify];
    } @finally {
        // swizzle back
        method_exchangeImplementations(original, swizzled);
    }
}

- (void)testPerformInputWhenValidNormalMove {
    [self doTestPerformInputWithMove:[[JCSFlipMove alloc] initWithStartRow:17 startColumn:23 direction:JCSHexDirectionNW]];
}

- (void)testPerformInputWhenValidSkipMove {
    [self doTestPerformInputWithMove:[[JCSFlipMove alloc] init]];
}

@end
