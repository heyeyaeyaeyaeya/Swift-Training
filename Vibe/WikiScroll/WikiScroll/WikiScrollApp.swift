//
//  WikiScrollApp.swift
//  WikiScroll
//
//  Created by Sergey Leontiev on 6. 2. 2026..
//

import SwiftUI
import CoreData

@main
struct WikiScrollApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
