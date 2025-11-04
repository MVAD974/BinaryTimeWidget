//
//  TimeWidgetBundle.swift
//  TimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import WidgetKit
import SwiftUI

@main
struct TimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimeWidget() // This is the only one we've built
        
        // We can add these back later if you build them
        // TimeWidgetControl()
        // TimeWidgetLiveActivity()
    }
}
