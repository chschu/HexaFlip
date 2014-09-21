//
//  JCSFlipUIBaseScreenTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 01.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import XCTest

// extension that exposes internals to the test (overridden by "ForTest" subclass)
extension JCSFlipUIBaseScreen {
    
    func winSize() -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func invokeSuperVisit() {
    }
}

class JCSFlipUIBaseScreenTestS : XCTestCase {
    
    func testSuperVisitInvokedWhenVisible() {
        XCTAssertTrue(superVisitInvoked(screenWidth: 20, screenHeight:10, left:19, bottom:9, right:30, top:30))
        XCTAssertTrue(superVisitInvoked(screenWidth: 20, screenHeight:10, left:19, bottom:-30, right:30, top:1))
        XCTAssertTrue(superVisitInvoked(screenWidth: 20, screenHeight:10, left:-30, bottom:-30, right:1, top:1))
        XCTAssertTrue(superVisitInvoked(screenWidth: 20, screenHeight:10, left:-30, bottom:9, right:1, top:30))
    }
    
    func testSuperVisitInvokedWhenNotVisible() {
        XCTAssertFalse(superVisitInvoked(screenWidth: 20, screenHeight:10, left:19, bottom:10, right:30, top:30))
        XCTAssertFalse(superVisitInvoked(screenWidth: 20, screenHeight:10, left:20, bottom:9, right:30, top:30))
        XCTAssertFalse(superVisitInvoked(screenWidth: 20, screenHeight:10, left:-30, bottom:-30, right:1, top:0))
        XCTAssertFalse(superVisitInvoked(screenWidth: 20, screenHeight:10, left:-30, bottom:-30, right:0, top:1))
    }
    
    // check if [super visit] is invoked, depending on the screen size, and the bounds of the node in world space
    func superVisitInvoked(#screenWidth: CGFloat, screenHeight: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, top: CGFloat) -> Bool {
        let underTest = JCSFlipUIBaseScreenForTest(screenWidth: screenWidth, screenHeight: screenHeight, left: left, bottom: bottom, right: right, top: top)
        underTest.visit()
        return underTest.superVisitInvoked
    }
    
    class JCSFlipUIBaseScreenForTest : JCSFlipUIBaseScreen {
        
        let screenWidth: CGFloat
        let screenHeight: CGFloat
        let left: CGFloat
        let bottom: CGFloat
        let right: CGFloat
        let top: CGFloat
        var superVisitInvoked = false
        
        init(screenWidth: CGFloat, screenHeight: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, top: CGFloat) {
            self.screenWidth = screenWidth
            self.screenHeight = screenHeight
            self.left = left
            self.bottom = bottom
            self.right = right
            self.top = top
        }
        
        override func winSize() -> CGSize {
            return CGSize(width: screenWidth, height: screenHeight)
        }
        
        override func invokeSuperVisit() {
            superVisitInvoked = true
        }
        
        override func convertToWorldSpace(point: CGPoint) -> CGPoint {
            if point.x == 0 && point.y == 0 {
                return CGPoint(x: left, y: bottom)
            } else if point.x == screenWidth && point.y == screenHeight {
                return CGPoint(x: right, y: top)
            } else {
                XCTFail("unexpected invocation for point \(point)")
                return CGPoint()
            }
        }
    }
}