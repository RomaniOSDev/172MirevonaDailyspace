//
//  SystemSound.swift
//  172MirevonaDailyspace
//

import AudioToolbox

enum SystemSound {
    static func play(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }

    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
