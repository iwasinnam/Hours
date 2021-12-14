//
//  HoursApp.swift
//  Hours
//
//  Created by Ariel Steiner on 08/12/2021.
//

import SwiftUI

@main
struct HoursApp: App {
    let persistenceController = PersistenceController.shared
    let locationMonitor = LocationMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationMonitor)
        }
    }
}
