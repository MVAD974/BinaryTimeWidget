//
//  StyleManager.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import Foundation
import SwiftUI
import WidgetKit // Needed to reload the widget

/// An observable class that manages loading and saving the widget's style.
/// This uses an App Group UserDefaults to share data between the app and the widget.
@Observable
class StyleManager {
    
    /// The style currently being edited or displayed.
    var style: WidgetStyle {
        didSet {
            // Anytime the style changes, save it.
            saveStyle()
            
            // Tell the widget to update its look.
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// The key used to save the style in UserDefaults.
    private let userDefaultsKey = "widgetStyle"
    
    /// The shared UserDefaults suite for the App Group.
    /// **IMPORTANT:** Replace with your group name if different.
    private let userDefaults = UserDefaults(suiteName: "group.Me.BinaryTimeWidget")

    init() {
        // Load the saved style, or use the default if none exists.
        self.style = Self.loadStyle()
    }
    
    /// Saves the current style to the App Group UserDefaults.
    private func saveStyle() {
        guard let defaults = userDefaults else {
            print("Error: App Group UserDefaults could not be found.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(style)
            defaults.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving style: \(error.localizedDescription)")
        }
    }
    
    /// A static function to load the style, usable by the widget.
    static func loadStyle() -> WidgetStyle {
        guard let defaults = UserDefaults(suiteName: "group.Me.BinaryTimeWidget") else {
            return .default
        }
        
        guard let data = defaults.data(forKey: "widgetStyle") else {
            return .default
        }
        
        do {
            let decoder = JSONDecoder()
            let style = try decoder.decode(WidgetStyle.self, from: data)
            return style
        } catch {
            print("Error loading style, using default: \(error.localizedDescription)")
            return .default
        }
    }
}
