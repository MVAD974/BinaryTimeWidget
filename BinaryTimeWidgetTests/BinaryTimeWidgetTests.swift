//
//  BinaryTimeWidgetTests.swift
//  BinaryTimeWidgetTests
//
//  Created by Marc Vadier on 04/11/2025.
//

import Testing
@testable import BinaryTimeWidget
import WidgetKit

struct BinaryTimeWidgetTests {

    @Test func digitToBinary_basic() async throws {
        #expect(TimeConverter.digitToBinary(0) == [0,0,0,0])
        #expect(TimeConverter.digitToBinary(1) == [0,0,0,1])
        #expect(TimeConverter.digitToBinary(8) == [1,0,0,0])
        #expect(TimeConverter.digitToBinary(9) == [1,0,0,1])
    }

    @Test func timeConversion_layersCount() async throws {
        let layers = TimeConverter.getTimeAsBinaryLayers(from: Date())
        #expect(layers.count == 4)
        layers.forEach { #expect($0.count == 4) }
    }

    @Test func dateConversion_layersCount() async throws {
        let layers = TimeConverter.getDateAsBinaryLayers(from: Date())
        #expect(layers.count == 4)
        layers.forEach { #expect($0.count == 4) }
    }

    @Test func simpleEntry_accessibilityLabel() async throws {
        let now = Date(timeIntervalSince1970: 1730000000) // fixed reference date
        let timeLayers = TimeConverter.getTimeAsBinaryLayers(from: now)
        let dateLayers = TimeConverter.getDateAsBinaryLayers(from: now)
        let style = WidgetStyle.defaultStyle(for: .systemSmall)
        let entry = SimpleEntry(date: now, timeBinaryLayers: timeLayers, dateBinaryLayers: dateLayers, style: style)
        let label = entry.accessibilityLabel
        // Basic checks contain key substrings
        #expect(label.contains("Time"))
        #expect(label.contains("Date"))
    }
}
