//
//  AppDelegate.swift
//  SpiderCards-2
//
//  Created by Maverick on 2020/11/11.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let game = Game(cardPacks: 8, cardTypes: 2)
//        let currentCardStack = CardStack(id: 0, cards: game.currentSubStack, mask: [0])
        let contentView = GameView(game: game)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

//    func resize() {
//        var windowFrame = window.frame
//        let oldWidth = windowFrame.size.width
//        let oldHeight = windowFrame.size.height
//        let toAdd = CGFloat(myDynamicNumber)
//        let newWidth = oldWidth + toAdd
//        let newHeight = oldHeight + toAdd
//        windowFrame.size = NSMakeSize(newWidth, newHeight)
//        window.setFrame(windowFrame, display: true)
//    }

}

