//
//  knock_App.swift
//  knockα
//
//  Created by konosuke kawata on 2026/04/19.
//

import SwiftUI
import FirebaseCore


@main
struct knock_App: App {
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
