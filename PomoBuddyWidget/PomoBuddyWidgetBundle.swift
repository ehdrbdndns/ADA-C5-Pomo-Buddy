//
//  PomoBuddyWidgetBundle.swift
//  PomoBuddyWidget
//
//  Created by Donggyun Yang on 8/21/25.
//

import WidgetKit
import SwiftUI

@main
struct PomoBuddyWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomoBuddyWidget()
        PomoBuddyWidgetControl()
        PomoBuddyWidgetLiveActivity()
    }
}
