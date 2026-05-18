//
//  MirevonaManager.swift
//  172MirevonaDailyspace
//

import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class MirevonaDailyspaceUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("MirevonaDailyspaceUpdateManagerInitial") var MirevonaDailyspaceUpdateManagerInitial: String?
    @AppStorage("MirevonaDailyspaceUpdateManagerStatus")  var MirevonaDailyspaceUpdateManagerStatus: Bool = false
    @AppStorage("MirevonaDailyspaceUpdateManagerFinal")   var MirevonaDailyspaceUpdateManagerFinal: String?
    
    @MainActor public static let shared = MirevonaDailyspaceUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var MirevonaDailyspaceUpdateManagerWindow: UIWindow?
    
    internal var MirevonaDailyspaceUpdateManagerSessionStarted = false
    internal var MirevonaDailyspaceUpdateManagerTokenHex = ""
    internal var MirevonaDailyspaceUpdateManagerSession: Session
    internal var MirevonaDailyspaceUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("MirevonaDailyspaceUpdateManager init -> \(debugRand)")
        self.MirevonaDailyspaceUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        MirevonaDailyspaceUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://powrorwnw.lol/privacy"
        paramRef = "data"
        
        MirevonaDailyspaceUpdateManagerWindow = window
        
        MirevonaDailyspaceUpdateManagerSetupAppsFlyer(appID: "6768581614", devKey: "tJsSfCnB2V4hVnXVQQoHCH")
        
        completion(.success("Initialization completed successfully"))
    }
    
    }
