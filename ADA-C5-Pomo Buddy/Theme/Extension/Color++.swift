
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
    
    static let black = Color(hex: "#000000")
    static let white = Color(hex: "#FFFFFF")
    
    static let title = Color(hex: "#2A2818")
    static let caption1 = Color(hex: "#4A5565")
    
    static let start = Color(hex: "#FFFEFB")
    static let focus = Color(hex: "#FFFAEA")
    static let rest = Color(hex: "#F5F8FF")
    
    static let red1 = Color(hex: "#FF6467")
    static let red2 = Color(hex: "#790002")
    static let red3 = Color(hex: "#250000")
    
    static let grey10 = Color(hex: "#A2A1A1")
    static let grey20 = Color(hex: "#858585")
    static let grey30 = Color(hex: "#D1D5DC")
    static let grey40 = Color(hex: "#F9FAFB")
    static let grey50 = Color(hex: "#F3F3F5")
    
    static let yellow1 = Color(hex: "#FAE363")
    static let yellow2 = Color(hex: "#452200")
    static let yellow3 = Color(hex: "#973C00")
    static let yellow4 = Color(hex: "#DEAE00")
    
    static let blue1 = Color(hex: "#2763BC")
    static let blue2 = Color(hex: "#428EFF")
    static let blueDim20 = Color(hex: "#2763BC").opacity(0.2)
    
    static let toggle = Color(hex: "#CCCED4")

    static let redDim10 = Color(hex: "#FF6467").opacity(0.1)
    static let blackDim20 = Color(hex: "#000000").opacity(0.2)
    static let greyDim50 = Color(hex: "#E9E9E9").opacity(0.5)
    static let yellowDim20 = Color(hex: "#FAE363").opacity(0.2)
}
