//
//  JCSFlipUIMainMenuScreenTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 04.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import GameKit
import XCTest

// extension that exposes internals to the test (overridden by "ForTest" subclass)
extension JCSFlipUIMainMenuScreen {
    
    func isLocalPlayerAuthenticated() -> Bool {
        return false
    }
}

class JCSFlipUIMainMenuScreenTest : XCTestCase {
    
    let underTest = JCSFlipUIMainMenuScreenForTest()
    var events: [NSNotification] = []

    override func setUp() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventTriggered:", name: nil, object: nil)
    }
    
    override func tearDown() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func testEventTriggeredWhenPlaySingleButtonActivated() {
        playSingleButtonForScreen(underTest).activate()
        XCTAssertEqual(["JCS_FLIP_UI_PLAY_SINGLE_EVENT_NAME"], events.map { notification in notification.name })
    }

    func testEventTriggeredWhenPlayMultiButtonActivated() {
        playMultiButtonForScreen(underTest).activate()
        XCTAssertEqual(["JCS_FLIP_UI_PLAY_MULTI_EVENT_NAME"], events.map { notification in notification.name })
    }
    
    func testPlayMultiButtonState() {
        // activate screen while player is not authenticated
        underTest.authenticationStatus = false
        underTest.willActivateScreen()
        XCTAssertFalse(playMultiButtonForScreen(underTest).isEnabled(), "button must be initially disabled if player is not authenticated")

        // authenticate player while screen is active
        underTest.authenticationStatus = true
        XCTAssertTrue(playMultiButtonForScreen(underTest).isEnabled(), "button must be enabled when player is authenticated")
        
        // deauthenticate player while screen is active
        underTest.authenticationStatus = false
        XCTAssertFalse(playMultiButtonForScreen(underTest).isEnabled(), "button must stay disabled when player is deauthenticated")
 
        // authenticate player while screen is inactive
        underTest.didDeactivateScreen()
        underTest.authenticationStatus = true
        XCTAssertFalse(playMultiButtonForScreen(underTest).isEnabled(), "button must remain unchanged after screen has been deactivated")

        // activate screen while player is authenticated
        underTest.willActivateScreen()
        XCTAssertTrue(playMultiButtonForScreen(underTest).isEnabled(), "button must be initially enabled if player is authenticated")

        // deauthenticate player while screen is inactive
        underTest.didDeactivateScreen()
        underTest.authenticationStatus = false
        XCTAssertTrue(playMultiButtonForScreen(underTest).isEnabled(), "button must remain unchanged after screen has been deactivated")
    }
    
    func descendantOfNode(node: CCNode, indexes: UInt...) -> CCNode {
        var cur = node
        for index in indexes {
            cur = cur.children.objectAtIndex(index) as CCNode
        }
        return cur
    }

    func playSingleButtonForScreen(screen: JCSFlipUIMainMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 0, 0) as JCSButton
    }
    
    func playMultiButtonForScreen(screen: JCSFlipUIMainMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 0, 1) as JCSButton
    }
    
    func eventTriggered(notification: NSNotification) {
        events.append(notification)
    }
    
    class JCSFlipUIMainMenuScreenForTest : JCSFlipUIMainMenuScreen {
        
        private var status = false
        var authenticationStatus: Bool {
            get {
                return status
            }
            set {
                status = newValue
                NSNotificationCenter.defaultCenter().postNotificationName(GKPlayerAuthenticationDidChangeNotificationName, object: nil)
            }
        }
        
        override func isLocalPlayerAuthenticated() -> Bool {
            return authenticationStatus
        }
    }
}