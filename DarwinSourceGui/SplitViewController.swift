//
//  ViewController.swift
//  DarwinSourceGui
//
//  Created by John Othwolo on 5/14/21.
//  Copyright © 2021 PureDarwin. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.window?.setAutorecalculatesContentBorderThickness(false, for: .minY)
//        self.view.window?.setContentBorderThickness(24.0, for: .minY)
        // ContentBorderThickness(24.0 forEdge:NSMinYEdge);
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return .zero
    }
    
}
