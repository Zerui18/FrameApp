//
//  Setting.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import Foundation
import Combine

extension UserDefaults {
    static let shared: UserDefaults = .init(suiteName: "com.Zerui.framepreferences")!
}

enum SettingKey: String {
    case isEnabled, disabledOnLPM, pauseInApps, syncRingerVolume, fadeEnabled, fadeAlpha, fadeInactivity, fixBlur, videoPath, videoVolume, parallexTrail, parallexNPages
}

enum SettingDomain: String {
    case both, homescreen, lockscreen
}

protocol EncodedSetting: Codable {}

@propertyWrapper
class Setting<Value: Codable>: NSObject, ObservableObject {
    
    // MARK: Privates
    /// The key.
    private let domain: String
    private let key: String
    private var userDefaultKey: String {
        "\(domain).\(key)"
    }
    
    /// The underlying value for wrappedValue.
    private var value: Value {
        willSet {
            // Trigger publisher whenever the underlying value willChange.
            objectWillChange.send()
        }
        didSet {
            changeHandler?(value)
        }
    }
    
    private var changeHandler: ((Value) -> Void)?
    
    // MARK: Property wrapper
    var projectedValue: Setting<Value> { self }
    var wrappedValue: Value {
        get {
            value
        }
        set {
            UserDefaults.shared.setValue(newValue, forKey: userDefaultKey)
            value = newValue
        }
    }

    // MARK: Init
    convenience init(domain: SettingDomain, key: SettingKey, defaultValue: Value) {
        self.init(domainRaw: domain.rawValue, keyRaw: key.rawValue, defaultValue: defaultValue)
    }
    
    fileprivate init(domainRaw: String, keyRaw: String, defaultValue: Value) {
        self.domain = domainRaw
        self.key = keyRaw
        // We set the default value first just so that we can use `self`.
        self.value = defaultValue
        super.init()
        // Now we properly retrieve the actual value, if any.
        if Value.self is EncodedSetting.Type,
           let value = UserDefaults.shared.data(forKey: userDefaultKey).flatMap({ try? JSONDecoder().decode(Value.self, from: $0) }) {
            self.value = value
        }
        else if let value = UserDefaults.shared.value(forKey: userDefaultKey) as? Value {
            self.value = value
        }
        // Use KVO to update value with changes from the defaults.
        UserDefaults.shared.addObserver(self, forKeyPath: userDefaultKey, options: [.new], context: nil)
    }
    
    // MARK: Deinit
    deinit {
        UserDefaults.shared.removeObserver(self, forKeyPath: userDefaultKey)
    }
    
    // MARK: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == key, let change = change, let newValue = change[.newKey] as? Value
        else { return }
        
        value = newValue
    }
    
    // MARK: Value Change
    func setChangeHandler(_ handler: ((Value) -> Void)?) {
        self.changeHandler = handler
    }
}

extension Setting where Value: EncodedSetting {
    var wrappedValue: Value {
        get {
            value
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.shared.setValue(data, forKey: userDefaultKey)
            value = newValue
        }
    }
}
