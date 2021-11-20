//
//  SettingToggle.swift
//  FrameApp
//
//  Created by Zerui Chen on 20/11/21.
//

import SwiftUI

struct SettingToggle: View {
    
    init(title: String, forKey key: SettingKey, inDomain domain: SettingDomain, defaultValue: Bool) {
        self.title = title
        self._setting = .init(domain: domain, key: key, defaultValue: defaultValue)
    }
    
    let title: String
    
    @Setting var setting: Bool
    
    var body: some View {
        if #available(iOS 14.0, *) {
        Toggle(title, isOn: $setting)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        else {
            Toggle(title, isOn: $setting)
        }
    }
    
}
