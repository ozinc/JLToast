/*
 * JLToast.swift
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                    Version 2, December 2004
 *
 * Copyright (C) 2013-2015 Su Yeol Jeon
 *
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *
 *  0. You just DO WHAT THE FUCK YOU WANT TO.
 *
 */

import UIKit

public struct JLToastDelay {
    public static let ShortDelay: NSTimeInterval = 2.0
    public static let LongDelay: NSTimeInterval = 3.5
}

@objc public class JLToast: NSOperation {

    public var view: JLToastViewProtocol = JLToastView()

    public var delay: NSTimeInterval = 0
    public var duration: NSTimeInterval = JLToastDelay.LongDelay

    private var _executing = false
    override public var executing: Bool {
        get {
            return self._executing
        }
        set {
            self.willChangeValueForKey("isExecuting")
            self._executing = newValue
            self.didChangeValueForKey("isExecuting")
        }
    }

    private var _finished = false
    override public var finished: Bool {
        get {
            return self._finished
        }
        set {
            self.willChangeValueForKey("isFinished")
            self._finished = newValue
            self.didChangeValueForKey("isFinished")
        }
    }

    override public var asynchronous: Bool {
        return true
    }

    internal var window: UIWindow {
        for window in UIApplication.sharedApplication().windows {
            if NSStringFromClass(window.dynamicType) == "UITextEffectsWindow" {
                return window as! UIWindow
            }
        }
        return UIApplication.sharedApplication().windows.first as! UIWindow
    }

    public init(view: JLToastViewProtocol) {
        self.view = view
    }

    public func show() {
        JLToastCenter.defaultCenter().addToast(self)
    }

    override public func start() {
        self.executing = true
        dispatch_async(dispatch_get_main_queue(), { [unowned self] () in
            self.view.updateView()
            self.window.addSubview(self.view as! UIView)
            UIView.animateWithDuration(
                0.5,
                delay: self.delay,
                options: .BeginFromCurrentState,
                animations: { [unowned self] () in
                    self.view.view.frame.origin.y -= self.view.view.frame.height
                },
                completion: { [unowned self] (completed) in

                    UIView.animateWithDuration(0.2, delay: self.duration, options: .allZeros, animations: { [unowned self] () in
                        self.view.view.frame.origin.y += self.view.view.frame.height
                        }, completion: { [unowned self] (completed) in
                            self.view.view.removeFromSuperview()
                            self.finish()
                        })
                }
            )
            })
    }

    public func finish() {
        self.executing = false
        self.finished = true
    }

}
