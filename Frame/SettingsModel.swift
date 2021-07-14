//
//  Settings.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import Foundation
import Combine

let defaults = UserDefaults(suiteName: "com.Zerui.framepreferences")!

enum SettingKeys: String {
    case isEnabled, disabledOnLPM, mutedLockscreen, mutedHomescreen, pauseInApps, syncRingerVolume, fadeEnabled, fadeAlpha, fadeInactivity, fixBlur, videoURLHomescreen, videoURLLockscreen
    case videoURLShared = "videoURL"
}

@propertyWrapper
class Setting<Value>: NSObject, ObservableObject {
    
    // MARK: Privates
    /// They key.
    private let key: SettingKeys
    
    /// The underlying value for wrappedValue.
    private var value: Value {
        willSet {
            // Trigger publisher whenever the underlying value willChange.
            objectWillChange.send()
        }
    }
    
    // MARK: Property wrapper
    var projectedValue: Setting<Value> { self }
    var wrappedValue: Value {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    // MARK: Init
    init(key: SettingKeys, defaultValue: Value) {
        self.key = key
        self.value = defaults.value(forKey: key.rawValue) as? Value ?? defaultValue
        super.init()
        // Use KVO to update value with changes from the defaults.
        defaults.addObserver(self, forKeyPath: key.rawValue, options: [.new], context: nil)
    }
    
    // MARK: Deinit
    deinit {
        defaults.removeObserver(self, forKeyPath: key.rawValue)
    }
    
    // MARK: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, keyPath == key.rawValue, let newValue = change[.newKey] as? Value else {
            return
        }
        
        value = newValue
    }
    
}
