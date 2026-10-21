//
//  TouchGestureMapping.swift
//  MeloNX
//

import Foundation
import Melo_Controller

enum TouchGesture: String, Codable, CaseIterable, Identifiable {
    case swipeUp
    case swipeDown
    case swipeLeft
    case swipeRight
    case doubleTap
    case twoFingerSwipeUp
    case twoFingerSwipeDown
    case twoFingerSwipeLeft
    case twoFingerSwipeRight
    case twoFingerDoubleTap
    case longPress
    case twoFingerLongPress

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .swipeUp: return "Swipe Up"
        case .swipeDown: return "Swipe Down"
        case .swipeLeft: return "Swipe Left"
        case .swipeRight: return "Swipe Right"
        case .doubleTap: return "Double Tap"
        case .twoFingerSwipeUp: return "Two-Finger Swipe Up"
        case .twoFingerSwipeDown: return "Two-Finger Swipe Down"
        case .twoFingerSwipeLeft: return "Two-Finger Swipe Left"
        case .twoFingerSwipeRight: return "Two-Finger Swipe Right"
        case .twoFingerDoubleTap: return "Two-Finger Double Tap"
        case .longPress: return "Long Press"
        case .twoFingerLongPress: return "Two-Finger Long Press"
        }
    }

    var iconName: String {
        switch self {
        case .swipeUp: return "arrow.up"
        case .swipeDown: return "arrow.down"
        case .swipeLeft: return "arrow.left"
        case .swipeRight: return "arrow.right"
        case .doubleTap: return "hand.tap.fill"
        case .twoFingerSwipeUp: return "arrow.up.square"
        case .twoFingerSwipeDown: return "arrow.down.square"
        case .twoFingerSwipeLeft: return "arrow.left.square"
        case .twoFingerSwipeRight: return "arrow.right.square"
        case .twoFingerDoubleTap: return "hand.tap"
        case .longPress: return "timer"
        case .twoFingerLongPress: return "timer.square"
        }
    }
}

struct TouchGestureMapping: Codable, Hashable {
    private var buttonIds: [String: String]

    init() {
        buttonIds = [
            TouchGesture.swipeUp.rawValue: VirtualControllerButton.dPadUp.id,
            TouchGesture.swipeDown.rawValue: VirtualControllerButton.dPadDown.id,
            TouchGesture.swipeLeft.rawValue: VirtualControllerButton.dPadLeft.id,
            TouchGesture.swipeRight.rawValue: VirtualControllerButton.dPadRight.id,
            TouchGesture.doubleTap.rawValue: VirtualControllerButton.A.id,
            TouchGesture.twoFingerSwipeLeft.rawValue: VirtualControllerButton.X.id,
            TouchGesture.twoFingerSwipeRight.rawValue: VirtualControllerButton.Y.id,
            TouchGesture.twoFingerDoubleTap.rawValue: VirtualControllerButton.start.id,
            TouchGesture.twoFingerLongPress.rawValue: VirtualControllerButton.B.id,
        ]
    }

    subscript(gesture: TouchGesture) -> VirtualControllerButton? {
        get {
            buttonIds[gesture.rawValue].flatMap {
                VirtualControllerButton.bindable(id: $0)
            }
        }
        set {
            buttonIds[gesture.rawValue] = newValue?.id
        }
    }
}
