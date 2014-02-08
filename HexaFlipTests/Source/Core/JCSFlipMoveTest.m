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
    _delayForBlock = [[NSMutableDictionary alloc] init];
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

@interface JCSFlipMoveTest : SenTestCase
@end

@implementation JCSFlipMoveTest {
    // each entry is an NSArray containing a NSNumber (delay, index 0) and a dispatch_block_t (block, index 1)
    NSMutableArray *_blockInfo;
}

- (void)testInitMove {
    JCSFlipMove *move = [[JCSFlipMove alloc] initWithStartRow:1 startColumn:4 direction:JCSHexDirectionNE];
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 1, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionNE, nil);
}

- (void)testInitSkip {
    JCSFlipMove *move = [[JCSFlipMove alloc] initSkip];
    
    STAssertTrue(move.skip, nil);
    STAssertThrows([move startRow], nil);
    STAssertThrows([move startColumn], nil);
    STAssertThrows([move direction], nil);
}

- (void)testMove {
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:3 startColumn:4 direction:JCSHexDirectionSE];
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 3, nil);
    STAssertEquals(move.startColumn, 4, nil);
    STAssertEquals(move.direction, JCSHexDirectionSE, nil);
}

- (void)testSkip {
    JCSFlipMove *move = [JCSFlipMove moveSkip];
    
    STAssertTrue(move.skip, nil);
    STAssertThrows([move startRow], nil);
    STAssertThrows([move startColumn], nil);
    STAssertThrows([move direction], nil);
}

- (void)testMutable {
    JCSFlipMove *move = [JCSFlipMove moveSkip];
    
    move.skip = NO;
    move.startRow = 1;
    move.startColumn = 2;
    move.direction = JCSHexDirectionNW;
    
    STAssertFalse(move.skip, nil);
    STAssertEquals(move.startRow, 1, nil);
    STAssertEquals(move.startColumn, 2, nil);
    STAssertEquals(move.direction, JCSHexDirectionNW, nil);
}

- (void)testCopy {
    JCSFlipMove *move = [JCSFlipMove moveWithStartRow:32 startColumn:12 direction:JCSHexDirectionE];
    JCSFlipMove *copy = [move copy];
    
    STAssertFalse(move == copy, nil);
    STAssertTrue([copy class] == [JCSFlipMove class], nil);
    STAssertEquals(move.skip, copy.skip, nil);
    STAssertEquals(move.startRow, copy.startRow, nil);
    STAssertEquals(move.startColumn, copy.startColumn, nil);
    STAssertEquals(move.direction, copy.direction, nil);
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
    [self doTestPerformInputWithMove:[JCSFlipMove moveWithStartRow:17 startColumn:23 direction:JCSHexDirectionNW]];
}

- (void)testPerformInputWhenValidSkipMove {
    [self doTestPerformInputWithMove:[JCSFlipMove moveSkip]];
}

@end
