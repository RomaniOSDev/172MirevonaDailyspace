//
//  AppSettingsLink.swift
//  172MirevonaDailyspace
//

import Foundation

enum AppSettingsLink: String {
    case privacyPolicy = "https://mirevona172dailyspace.site/privacy/177"
    case termsOfUse = "https://mirevona172dailyspace.site/terms/177"

    var url: URL? {
        URL(string: rawValue)
    }
}
