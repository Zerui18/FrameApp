//
//  MoreTab.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI

struct MoreTab: View {
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
        
    var body: some View {
        // MARK: Title
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text("Settings")
                    .fontWeight(.bold)
                    .font(.largeTitle)
            }
            .padding([.leading, .trailing], 30)
            .padding(.top, 15)
            
            // MARK: Content
            Form {
                Section {
                    SettingToggle(title: "Enabled", forKey: .isEnabled, inDomain: .global, defaultValue: true)
                    SettingToggle(title: "Disable On LPM", forKey: .disabledOnLPM, inDomain: .global, defaultValue: true)
                    
                } header: {
                    Text("MASTER")
                        .neatenOn14()
                } footer: {
                    Text("Enable \"Disable on LPM\" to automatically disable Frame on Low Power Mode.")
                        .neatenOn14()
                }
                
                Section {
                    SettingToggle(title: "Pause in Apps", forKey: .pauseInApps, inDomain: .global, defaultValue: true)
                } footer: {
                    Text("Enable \"Pause in Apps\" to save battery.")
                        .neatenOn14()
                }
                
                Section {
                    FadeSettings()
                } header: {
                    Text("FADE")
                        .neatenOn14()
                } footer: {
                    Text("Be fully absorbed in your video wallpaper as the home screen icons fade to a set transparency after a set period of inactivity.")
                        .neatenOn14()
                }
                
                Section {
                    SettingToggle(title: "Sync Ringer Volume", forKey: .syncRingerVolume, inDomain: .global, defaultValue: false)
                } header: {
                    Text("MISC")
                        .neatenOn14()
                } footer: {
                    Text("This option allows you to change the ringer volume with the volume buttons when Frame is enabled, by syncing the ringer volume to the media volume.")
                        .neatenOn14()
                }

                Section {
                    SettingToggle(title: "Fix Blur", forKey: .syncRingerVolume, inDomain: .global, defaultValue: false)
                } footer: {
                    Text("Enable this option if the folders'/dock's backgrounds appear fixed despite the video playing below them. It's side-effect is mild to serious lagging when editing homescreen. Requires a respring to apply.")
                        .neatenOn14()
                }
            }
            .padding([.leading, .trailing], 5)
        }
    }
}

struct MoreTab_Previews: PreviewProvider {
    static var previews: some View {
        MoreTab()
    }
}

fileprivate extension Text {
    /// Mimick iOS 15's additional horizontal paddings on iOS 14 to make Form neater.
    func neatenOn14() -> some View {
        Group {
            if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 14 {
                self.padding([.leading, .trailing], 15)
            }
            else {
                self
            }
        }
    }
}
