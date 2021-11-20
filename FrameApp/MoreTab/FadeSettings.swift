//
//  FadeSettings.swift
//  FrameApp
//
//  Created by Zerui Chen on 20/11/21.
//

import SwiftUI

struct FadeSettings: View {
    
    @Setting(domain: .global, key: .fadeEnabled, defaultValue: true) var fadeEnabled: Bool
    @Setting(domain: .global, key: .fadeAlpha, defaultValue: 0.05) var fadeAlpha: Double
    @Setting(domain: .global, key: .fadeInactivity, defaultValue: 4.0) var fadeInactivity: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            if #available(iOS 14, *) {
                Toggle("Fade Enabled", isOn: $fadeEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            }
            else {
                Toggle("Fade Enabled", isOn: $fadeEnabled)
            }
            
            if fadeEnabled {
                Text(String(format: "Fade Alpha: %.2f", fadeAlpha))
                
                Slider(value: $fadeAlpha, in: 0.0...1.0, step: 0.05) {
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }
                
                Text(String(format: "Inactivity Duration: %.1f", fadeInactivity))
                
                Slider(value: $fadeInactivity, in: 1.0...10.0, step: 0.5) {
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("10")
                }
            }
        }
    }
}

struct FadeSettings_Previews: PreviewProvider {
    static var previews: some View {
        FadeSettings()
    }
}
