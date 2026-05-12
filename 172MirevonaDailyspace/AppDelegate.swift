//
//  AppDelegate.swift
//  172MirevonaDailyspace
//
//  Created by Roman on 5/12/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.configureGlobalChrome()
        return true
    }

    private static func configureGlobalChrome() {
        let titleColor = UIColor(named: "AppTextPrimary") ?? .white
        let tint = UIColor(named: "AppPrimary") ?? .systemOrange

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.backgroundColor = .clear
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: titleColor]
        nav.largeTitleTextAttributes = [.foregroundColor: titleColor]

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = nav
        navBar.scrollEdgeAppearance = nav
        navBar.compactAppearance = nav
        navBar.compactScrollEdgeAppearance = nav
        navBar.isTranslucent = true
        navBar.tintColor = tint

        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear

        UIScrollView.appearance().backgroundColor = .clear

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "AppAccent") ?? tint
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "AppTextSecondary") ?? .lightGray

        let windowBg = UIColor(named: "AppBackground") ?? UIColor(red: 0.18, green: 0.12, blue: 0.20, alpha: 1)
        UIWindow.appearance().backgroundColor = windowBg
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

