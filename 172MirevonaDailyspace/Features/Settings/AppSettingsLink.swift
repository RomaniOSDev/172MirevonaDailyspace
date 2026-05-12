//
//  AppSettingsLink.swift
//  172MirevonaDailyspace
//

import Foundation

enum AppSettingsLink: String {
    case privacyPolicy = "https://example.com/privacy-policy"
    case termsOfUse = "https://example.com/terms"

    var url: URL? {
        URL(string: rawValue)
    }
}
