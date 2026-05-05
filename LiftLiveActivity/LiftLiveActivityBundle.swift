// LiftLiveActivityBundle.swift
// LiftLiveActivity Extension — @main entry point

import WidgetKit
import SwiftUI

@main
struct LiftLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        RestTimerLiveActivity()
    }
}
