//
//  JCSFlipUIPlayerMenuScreenTest.swift
//  HexaFlip
//
//  Created by Christian Schuster on 05.11.14.
//  Copyright (c) 2014 Christian Schuster. All rights reserved.
//

import Foundation
import GameKit
import XCTest

class JCSFlipUIPlayerMenuScreenTest : XCTestCase {
    
    let underTest = JCSFlipUIPlayerMenuScreen()
    var events: [NSNotification] = []
    
    override func setUp() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventTriggered:", name: nil, object: nil)
    }
    
    override func tearDown() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func testEventTriggeredWhenBackButtonActivated() {
        backButtonForScreen(underTest).activate()
        XCTAssertEqual(["JCS_FLIP_UI_BACK_EVENT_NAME"], events.map { notification in notification.name })
    }
    
    func testEventsWhenPlayerTypesChangedAndPlayButtonActivated() {
        let descriptionForLocalPlayer = "(Local Player)"
        let descriptionForAIEasyPlayer = "(AI player; (NegaScout Algorithm; (Transposition Table; Size 1000000); (Possession Heuristic); Depth 1))"
        let descriptionForAIMediumPlayer = "(AI player; (NegaScout Algorithm; (Transposition Table; Size 1000000); (Possession Heuristic); Depth 4))"
        let descriptionForAIHardPlayer = "(AI player; (NegaScout Algorithm; (Transposition Table; Size 1000000); (Possession Heuristic); Depth 6))"
        
        checkEventsWhenActivatingButton(nil, expectedPlayerADescription: descriptionForLocalPlayer, expectedPlayerBDescription: descriptionForAIMediumPlayer)
        checkEventsWhenActivatingButton(playerAAIEasyButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIEasyPlayer, expectedPlayerBDescription: descriptionForAIMediumPlayer)
        checkEventsWhenActivatingButton(playerBLocalButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIEasyPlayer, expectedPlayerBDescription: descriptionForLocalPlayer)
        checkEventsWhenActivatingButton(playerAAIHardButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIHardPlayer, expectedPlayerBDescription: descriptionForLocalPlayer)
        checkEventsWhenActivatingButton(playerBAIMediumButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIHardPlayer, expectedPlayerBDescription: descriptionForAIMediumPlayer)
        checkEventsWhenActivatingButton(playerAAIMediumButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIMediumPlayer, expectedPlayerBDescription: descriptionForAIMediumPlayer)
        checkEventsWhenActivatingButton(playerBAIEasyButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIMediumPlayer, expectedPlayerBDescription: descriptionForAIEasyPlayer)
        checkEventsWhenActivatingButton(playerBAIHardButtonForScreen(underTest), expectedPlayerADescription: descriptionForAIMediumPlayer, expectedPlayerBDescription: descriptionForAIHardPlayer)
        checkEventsWhenActivatingButton(playerALocalButtonForScreen(underTest), expectedPlayerADescription: descriptionForLocalPlayer, expectedPlayerBDescription: descriptionForAIHardPlayer)
    }

    
    func checkEventsWhenActivatingButton(button: JCSButton?, expectedPlayerADescription: String, expectedPlayerBDescription: String) {
        events.removeAll()
        
        button?.activate()

        XCTAssertEqual(events.count, 0)
        
        playButtonForScreen(underTest).activate()
        
        XCTAssertEqual(events.count, 2)
        
        let prepareEvent = events[0]
        XCTAssertEqual(prepareEvent.name, "JCS_FLIP_UI_PREPARE_GAME_EVENT_NAME")
        XCTAssertNotNil(prepareEvent.userInfo)
        XCTAssertEqual(prepareEvent.userInfo!.count, 1)
        let prepareEventData = prepareEvent.userInfo!.values.first! as JCSFlipUIPrepareGameEventData
        XCTAssertNotNil(prepareEventData)
        XCTAssertEqual(prepareEventData.gameState.playerToMove, JCSFlipPlayerSide.A)
        XCTAssertEqual(prepareEventData.gameState.cellCountPlayerA, 3)
        XCTAssertEqual(prepareEventData.gameState.cellCountPlayerB, 3)
        XCTAssertEqual(prepareEventData.gameState.cellCountEmpty, 54)
        XCTAssertNil(prepareEventData.match)
        XCTAssertFalse(prepareEventData.animateLastMove)
        XCTAssertFalse(prepareEventData.moveInputDisabled)
        XCTAssertEqual(prepareEventData.playerA.description, expectedPlayerADescription)
        XCTAssertEqual(prepareEventData.playerB.description, expectedPlayerBDescription)
        
        let playEvent = events[1]
        XCTAssertEqual(playEvent.name, "JCS_FLIP_UI_PLAY_GAME_EVENT_NAME")
        XCTAssertNil(playEvent.userInfo)
    }


    func descendantOfNode(node: CCNode, indexes: UInt...) -> CCNode {
        var cur = node
        for index in indexes {
            cur = cur.children.objectAtIndex(index) as CCNode
        }
        return cur
    }
    
    func backButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 0, 0) as JCSButton
    }

    func playButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 0, 1) as JCSButton
    }

    func playerALocalButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 1, 0) as JCSButton
    }

    func playerAAIEasyButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 1, 1) as JCSButton
    }

    func playerAAIMediumButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 1, 2) as JCSButton
    }
    
    func playerAAIHardButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 1, 3) as JCSButton
    }

    func playerBLocalButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 2, 0) as JCSButton
    }
    
    func playerBAIEasyButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 2, 1) as JCSButton
    }
    
    func playerBAIMediumButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 2, 2) as JCSButton
    }
    
    func playerBAIHardButtonForScreen(screen: JCSFlipUIPlayerMenuScreen) -> JCSButton {
        return descendantOfNode(screen, indexes: 2, 3) as JCSButton
    }

    func eventTriggered(notification: NSNotification) {
        events.append(notification)
    }
}