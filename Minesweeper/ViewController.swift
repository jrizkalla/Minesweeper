//
//  ViewController.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentViewControllerAsSheet(BoardViewController(nibName: "BoardViewController.nib", bundle: NSBundle.mainBundle())!);

//        mainView.board = try? Board.createRandomBoard(60, height: 60, numBombs: 100, x: 0, y: 0);
//        let width = 50;
//        let height = 50;
//        let percent = 0.05;
//        print("Creating \(width) * \(height) board with \(Double(width) * Double(height) * percent) bombs");
////        mainView.board = try? Board.createRandomBoard(width, height: height, numBombs: Int(Double(width) * Double(height) * percent), x: 0, y: 0);
////        mainView.board = try? Board.createRandomBoard(70, height: 50, numBombs: 170, x: 0, y: 0);
//        mainView.initializer = try! BoardView.Initializer(width: width, height: height, numBombs: Int(Double(width) * Double(height) * percent), boardCreator: {try! Board.createRandomBoard($0, height: $1, numBombs: $2, x: $3, y: $4)});
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

