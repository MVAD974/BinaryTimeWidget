//
//  TimeConverter.swift
//  TimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import Foundation

// This struct holds all the logic for converting time into binary plots.
struct TimeConverter {
    
    /// 1. This replaces your `base10_to_base_b` function.
    /// It converts a single digit (0-9) into its 4-bit binary array.
    static func digitToBinary(_ n: Int) -> [Int] {
        if n == 0 {
            return [0, 0, 0, 0]
        }
        
        var digits: [Int] = []
        var temp_n = abs(n)
        
        while temp_n > 0 {
            let remainder = temp_n % 2
            digits.append(remainder)
            temp_n /= 2
        }
        
        // Pad the array with leading zeros to ensure it's 4 bits long
        let padding = [Int](repeating: 0, count: 4 - digits.count)
        
        // We reverse the digits (since we built it backwards) and add padding
        return padding + digits.reversed()
    }
    
    /// 2. This is the main function to get data for the widget.
    /// It takes a Date and returns the four stacked binary arrays.
    static func getTimeAsBinaryLayers(from date: Date) -> [[Int]] {
        let calendar = Calendar.current
        
        // Get the hour and minute
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // Get the four digits (e.g., 10:45 -> H1=1, H2=0, M1=4, M2=5)
        let hourDigit1 = hour / 10
        let hourDigit2 = hour % 10
        let minuteDigit1 = minute / 10
        let minuteDigit2 = minute % 10
        
        let allDigits = [hourDigit1, hourDigit2, minuteDigit1, minuteDigit2]
        
        // Convert each digit to its binary representation
        let binaryLayers = allDigits.map { digit in
            digitToBinary(digit)
        }
        
        return binaryLayers
    }

    /// 3. Extract date (day & month) into four binary layers (DDMM format: D1, D2, M1, M2)
    static func getDateAsBinaryLayers(from date: Date) -> [[Int]] {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)      // 1-31
        let month = calendar.component(.month, from: date)  // 1-12

        let dayDigit1 = day / 10
        let dayDigit2 = day % 10
        let monthDigit1 = month / 10
        let monthDigit2 = month % 10

        let digits = [dayDigit1, dayDigit2, monthDigit1, monthDigit2]
        return digits.map { digitToBinary($0) }
    }
}
