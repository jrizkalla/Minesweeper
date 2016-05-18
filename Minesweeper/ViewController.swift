//
//  ViewController.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var mainViewController: ViewController? = nil;

    @IBOutlet weak var mainView: BoardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        mainView.board = try? Board.createRandomBoard(60, height: 60, numBombs: 100, x: 0, y: 0);
        let width = 100;
        let height = 100;
        let percent = 0.07;
        print("Creating \(width) * \(height) board with \(Double(width) * Double(height) * percent) bombs");
//        mainView.board = try? Board.createRandomBoard(width, height: height, numBombs: Int(Double(width) * Double(height) * percent), x: 0, y: 0);
        mainView.board = try? Board.createRandomBoard(70, height: 50, numBombs: 170, x: 0, y: 0);
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

