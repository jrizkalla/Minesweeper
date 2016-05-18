//
//  AppDelegate.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var tui: TUI? = nil;

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        //tui = TUI();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

