// RestTimerAttributes.swift
// Lift Live Activity Extension — Shared attributes for rest timer
// ADD THIS FILE TO: LiveActivityExtension target (separate WidgetKit Extension in Xcode)

import ActivityKit
import Foundation

/// Shared between the main app and the WidgetKit extension.
/// Both targets must include this file (or a shared framework).
public struct RestTimerAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var restEndTime: Date
        public var exerciseName: String
        public var setNumber: Int
    }
    public var workoutName: String

    public init(workoutName: String) {
        self.workoutName = workoutName
    }
}
