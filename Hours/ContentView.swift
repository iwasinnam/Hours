//
//  ContentView.swift
//  Hours
//
//  Created by Ariel Steiner on 08/12/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.begin, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    enum Tabs : String {
        case hours
        case settings
    }

    @State var selectedTab : Tabs = .hours

    var body: some View {
        TabView(selection: $selectedTab) {
            HoursView()
                .tabItem {
                    Label(Tabs.hours.rawValue.capitalized,
                          systemImage: "person.badge.clock")
                }
                .tag(Tabs.hours)

            SettingsView()
                .tabItem {
                    Label(Tabs.hours.rawValue.capitalized,
                    systemImage: "gear")
                }
                .tag(Tabs.settings)
        }.onAppear {
            logger.log("App appeared")
        }.onDisappear {
            logger.log("App disappeared")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LocationMonitor())
    }
}
