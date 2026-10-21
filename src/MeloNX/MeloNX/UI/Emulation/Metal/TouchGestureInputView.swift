//
//  TouchGestureInputView.swift
//  MeloNX
//

import UIKit
import Melo_Controller

final class TouchGestureInputView: UIView {
    var mapping = TouchGestureMapping() {
        didSet { resetActiveInput() }
    }

    var onTouch: (() -> Void)?

    private weak var gamepad: VirtualControllerManager?
    private var activeButton: VirtualControllerButton?
    private var releaseWorkItem: DispatchWorkItem?
    private var singleSwipeDirection: TouchGesture?
    private var twoFingerSwipeDirection: TouchGesture?

    private let swipeThreshold: CGFloat = 24
    private let minimumButtonDuration: TimeInterval = 0.06

    init(gamepad: VirtualControllerManager) {
        self.gamepad = gamepad
        super.init(frame: .zero)

        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = true

        addGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("TouchGestureInputView is created in code")
    }

    func reset() {
        resetActiveInput()
        singleSwipeDirection = nil
        twoFingerSwipeDirection = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onTouch?()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        onTouch?()
    }

    private func addGestureRecognizers() {
        let singlePan = UIPanGestureRecognizer(target: self, action: #selector(handleSinglePan(_:)))
        singlePan.minimumNumberOfTouches = 1
        singlePan.maximumNumberOfTouches = 1

        let twoFingerPan = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPan.minimumNumberOfTouches = 2
        twoFingerPan.maximumNumberOfTouches = 2

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2

        let twoFingerDoubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerDoubleTap(_:)))
        twoFingerDoubleTap.numberOfTapsRequired = 2
        twoFingerDoubleTap.numberOfTouchesRequired = 2

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.45

        let twoFingerLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleTwoFingerLongPress(_:)))
        twoFingerLongPress.minimumPressDuration = 0.45
        twoFingerLongPress.numberOfTouchesRequired = 2

        [singlePan, twoFingerPan, doubleTap, twoFingerDoubleTap, longPress, twoFingerLongPress]
            .forEach(addGestureRecognizer)
    }

    @objc private func handleSinglePan(_ recognizer: UIPanGestureRecognizer) {
        handlePan(recognizer, isSingleFinger: true, directionSlot: &singleSwipeDirection)
    }

    @objc private func handleTwoFingerPan(_ recognizer: UIPanGestureRecognizer) {
        handlePan(recognizer, isSingleFinger: false, directionSlot: &twoFingerSwipeDirection)
    }

    private func handlePan(
        _ recognizer: UIPanGestureRecognizer,
        isSingleFinger: Bool,
        directionSlot: inout TouchGesture?
    ) {
        switch recognizer.state {
        case .began:
            directionSlot = nil

        case .changed:
            guard directionSlot == nil else { return }

            let translation = recognizer.translation(in: self)
            guard abs(translation.x) >= swipeThreshold || abs(translation.y) >= swipeThreshold else {
                return
            }

            let gesture: TouchGesture
            if abs(translation.x) > abs(translation.y) {
                gesture = isSingleFinger
                    ? (translation.x < 0 ? .swipeLeft : .swipeRight)
                    : (translation.x < 0 ? .twoFingerSwipeLeft : .twoFingerSwipeRight)
            } else {
                gesture = isSingleFinger
                    ? (translation.y < 0 ? .swipeUp : .swipeDown)
                    : (translation.y < 0 ? .twoFingerSwipeUp : .twoFingerSwipeDown)
            }

            directionSlot = gesture
            press(mapping[gesture], automaticallyRelease: true)

        case .ended, .cancelled, .failed:
            directionSlot = nil

        default:
            break
        }
    }

    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        press(mapping[.doubleTap], automaticallyRelease: true)
    }

    @objc private func handleTwoFingerDoubleTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        press(mapping[.twoFingerDoubleTap], automaticallyRelease: true)
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            press(mapping[.longPress], automaticallyRelease: false)
        case .ended, .cancelled, .failed:
            releaseActiveButton()
        default:
            break
        }
    }

    @objc private func handleTwoFingerLongPress(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            press(mapping[.twoFingerLongPress], automaticallyRelease: false)
        case .ended, .cancelled, .failed:
            releaseActiveButton()
        default:
            break
        }
    }

    private func press(_ button: VirtualControllerButton?, automaticallyRelease: Bool) {
        guard let button, activeButton == nil else { return }

        activeButton = button
        gamepad?.buttonPressed(button)

        guard automaticallyRelease else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.releaseActiveButton()
        }
        releaseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumButtonDuration, execute: workItem)
    }

    private func releaseActiveButton() {
        releaseWorkItem?.cancel()
        releaseWorkItem = nil

        guard let button = activeButton else { return }

        gamepad?.buttonReleased(button)
        activeButton = nil
    }

    private func resetActiveInput() {
        releaseActiveButton()
    }
}
