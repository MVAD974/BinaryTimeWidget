//
//  StyleManager.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import Foundation
import SwiftUI
import WidgetKit

/// A service to save and load widget styles based on widget family.
struct StyleManager {
    
    /// The shared UserDefaults suite for the App Group.
    private static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.Me.BinaryTimeWidget")
    }

    /// Generates a unique key for storing a style for a specific family.
    private static func key(for family: WidgetFamily) -> String {
        // e.g., "widgetStyle_systemSmall"
        "widgetStyle_\(family.description)"
    }
    
    /// Saves a specific style for a specific widget family.
    static func saveStyle(_ style: WidgetStyle, for family: WidgetFamily) {
        guard let defaults = userDefaults else {
            print("Error: App Group UserDefaults could not be found.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(style)
            let familyKey = key(for: family)
            defaults.set(data, forKey: familyKey)
            
            // Tell all widgets to reload (so they can pick up new styles)
            WidgetCenter.shared.reloadAllTimelines()
            
        } catch {
            print("Error saving style for \(family.description): \(error.localizedDescription)")
        }
    }
    
    /// Loads the saved style for a specific widget family.
    /// If no style is saved, it returns the default style for that family.
    static func loadStyle(for family: WidgetFamily) -> WidgetStyle {
        guard let defaults = userDefaults else {
            return .defaultStyle(for: family)
        }
        
        let familyKey = key(for: family)
        
        guard let data = defaults.data(forKey: familyKey) else {
            // No saved style found, return the default
            return .defaultStyle(for: family)
        }
        
        do {
            let decoder = JSONDecoder()
            let style = try decoder.decode(WidgetStyle.self, from: data)
            return style
        } catch {
            print("Error loading style for \(family.description), using default: \(error.localizedDescription)")
            return .defaultStyle(for: family)
        }
    }
}
