//
//  Setting.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

// TODO: Properly implement the encoding & decoding of non-basic, Codable settings.

import Foundation
import Combine
import SwiftUI

let none = Optional<Any>.none

extension UserDefaults {
    static let shared: UserDefaults = .init(suiteName: "com.Zerui.framepreferences")!
}

enum SettingKey: String {
    case isEnabled, disabledOnLPM, pauseInApps, syncRingerVolume, fadeEnabled, fadeAlpha, fadeInactivity, fixBlur, videoPath, videoVolume, parallexTrail, parallexNPages, isMuted
}

enum SettingDomain: String {
    case both, // override common values for homescreen and lockscreen
         homescreen,
         lockscreen,
         global // other global settings (eg., isEnabled, disabledOnLPM)
}

//protocol EncodedSetting: Codable {}

/// Wrapper for a UserDefaults setting.
@propertyWrapper
struct Setting<Value: Codable>: DynamicProperty {
    
    /// Actual object interfacing with UserDefaults.
    class Storage: NSObject, ObservableObject {
        
        private let userDefaultKey: String
        fileprivate var changeHandler: ((Value) -> Void)?
        
        init(userDefaultKey key: String, defaultValue: Value) {
            self.userDefaultKey = key
            // Now we properly retrieve the actual value, if any.
//            if Value.self is EncodedSetting.Type,
//               let value = UserDefaults.shared.data(forKey: userDefaultKey).flatMap({ try? JSONDecoder().decode(Value.self, from: $0) }) {
//                self.value = value
//            }
            if let value = UserDefaults.shared.value(forKey: key) as? Value {
                self.value = value
            }
            else {
                // Use default value.
                self.value = defaultValue
            }
            super.init()
            // Use KVO to update value with changes from the defaults.
            UserDefaults.shared.addObserver(self, forKeyPath: self.userDefaultKey, options: .new, context: nil)
        }
        
        /// Read-only property for the stored value.
        @Published private(set) var value: Value
        
        /// Write to the stored value.
        func write(_ newValue: Value) {
            value = newValue
            // First check is newValue == nil, which causes a crash if passed to setValue.
            if let optionalValue = newValue as? OptionalProtocol, optionalValue.isNil {
                UserDefaults.shared.removeObject(forKey: userDefaultKey)
            }
            // newValue is not nil, safe to proceed.
            else {
                UserDefaults.shared.setValue(newValue, forKey: userDefaultKey)
            }
        }

        // MARK: Deinit
        deinit {
            UserDefaults.shared.removeObserver(self, forKeyPath: userDefaultKey)
        }
        
        // MARK: KVO
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

            guard keyPath == userDefaultKey, let change = change
            else { return }
            
            let newValue = change[.newKey]!
            
            if newValue is NSNull {
                // Magic to set self.value to nil / pointer to Optional.none.
                // Essentially self.value = (Value *) nullptr
                withUnsafePointer(to: none) { ptr in
                    ptr.withMemoryRebound(to: Value.self, capacity: 1) { retypedPtr in
                        self.value = retypedPtr.pointee
                    }
                }
            }
            else {
                value = newValue as! Value
                changeHandler?(newValue as! Value)
            }
        }
    }
    
    /// The source of truth value.
    @ObservedObject private var storage: Storage
    
    // MARK: Property wrapper
    var wrappedValue: Value {
        get {
            storage.value
        }
        nonmutating set {
            storage.write(newValue)
        }
    }
    
    /// A binding to the value of this Setting.
    var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }

    // MARK: Init
    init(domain: SettingDomain, key: SettingKey, defaultValue: Value) {
        let userDefaultsKey = domain == .global ? key.rawValue : "\(domain.rawValue)/\(key.rawValue)"
        self.storage = Storage(userDefaultKey: userDefaultsKey, defaultValue: defaultValue)
    }
    
    // MARK: Value Change
    func setChangeHandler(_ handler: ((Value) -> Void)?) {
        self.storage.changeHandler = handler
    }
}

//extension Setting where Value: EncodedSetting {
//    var wrappedValue: Value {
//        get {
//            value
//        }
//        set {
//            let data = try! JSONEncoder().encode(newValue)
//            UserDefaults.shared.setValue(data, forKey: userDefaultKey)
//            value = newValue
//        }
//    }
//}
