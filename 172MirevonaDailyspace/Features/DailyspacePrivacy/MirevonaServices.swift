//
//  MirevonaServices.swift
//  172MirevonaDailyspace
//

import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension MirevonaDailyspaceUpdateManager {
    
        @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
            let debugLocal = Int.random(in: 1...100)
            print("appsFl succes ->: \(debugLocal)")
            
            let rawData   = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
            let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
            
            let finalJson = """
        {
            "\(appsRefKey)": \(rawString),
            "\(appIDRef)": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
            "\(langRef)": "\(Locale.current.languageCode ?? "")",
            "\(tokenRef)": "\(MirevonaDailyspaceUpdateManagerTokenHex)"
        }
        """
            
            let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
            
            MirevonaDailyspaceUpdateManager.shared.MirevonaDailyspaceUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
                switch result {
                case .success(let msg):
                    self.MirevonaDailyspaceUpdateManagerSendNotice(name: "RemMess", message: msg)
                case .failure:
                    self.MirevonaDailyspaceUpdateManagerSendNoticeError(name: "RemMess")
                }
            }
        }
        
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
        print("onConversionDataFail | Error: \(error.localizedDescription)")
        MirevonaDailyspaceUpdateManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func MirevonaDailyspaceUpdateManagerHandleActiveSession() {
        if !MirevonaDailyspaceUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            print("MirevonaDailyspaceUpdateManagerHandleActiveSession -> localValue = \(localValue)")
            
            AppsFlyerLib.shared().start()
            MirevonaDailyspaceUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func MirevonaDailyspaceUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        print("MirevonaDailyspaceUpdateManagerSetupAppsFlyer -> sumOfKeys: \(sumOfKeys)")
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func MirevonaDailyspaceUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MirevonaDailyspaceUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func MirevonaDailyspaceUpdateManagerSendNotice(name: String, message: String) {
        print("MirevonaDailyspaceUpdateManagerSendNotice -> \(message.count)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func MirevonaDailyspaceUpdateManagerSendNoticeError(name: String) {
        print("MirevonaDailyspaceUpdateManagerSendNoticeError -> \(name.count * 2)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func MirevonaDailyspaceUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("MirevonaDailyspaceUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func MirevonaDailyspaceUpdateManagerIsSessionInit() -> Bool {
        print("MirevonaDailyspaceUpdateManagerIsSessionInit -> \(MirevonaDailyspaceUpdateManagerSessionStarted)")
        return MirevonaDailyspaceUpdateManagerSessionStarted
    }
    
    public func MirevonaDailyspaceUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("MirevonaDailyspaceUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func MirevonaDailyspaceUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("MirevonaDailyspaceUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func MirevonaDailyspaceUpdateManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        MirevonaDailyspaceUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("MirevonaDailyspaceUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func MirevonaDailyspaceUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("MirevonaDailyspaceUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func MirevonaDailyspaceUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("MirevonaDailyspaceUpdateManagerMinimalRandCheck -> \(val)")
    }
        
    }

struct MirevonaDailyspaceLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding(.top, 30)
            }
        }
    }
}
