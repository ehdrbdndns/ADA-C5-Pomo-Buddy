import SwiftUI


extension Font {

    private static var appFontFamily: String {
        Locale.current.language.languageCode?.identifier == "ko" ? "Paperlogy" : "Quicksand"
    }
    
    // MARK: - Bold
    
    /// Menlo Bold, 40pt
    static let B1: Font = .custom("Menlo", size: 36).weight(.bold)

    /// Menlo Bold, 64pt
    static let B2: Font = .custom("Menlo", size: 64).weight(.bold)
    
    /// Menlo Bold, 42pt
    static let B3: Font = .custom("Menlo", size: 42).weight(.bold)

    // MARK: - SemiBold
    
    /// Quicksand SemiBold, 17pt
    static let SB1: Font = .custom(appFontFamily, size: 17).weight(.semibold)
    /// Quicksand SemiBold, 15pt
    static let SB2: Font = .custom(appFontFamily, size: 15).weight(.semibold)

    // MARK: - Medium
    
    /// Quicksand Medium, 10pt
    static let M1: Font = .custom(appFontFamily, size: 10).weight(.medium)
    
    /// Quicksand Medium, 12pt
    static let M2: Font = .custom(appFontFamily, size: 12).weight(.medium)
    
    /// Quicksand Medium, 14pt
    static let M3: Font = .custom(appFontFamily, size: 14).weight(.medium)
    
    /// Quicksand Medium, 16pt
    static let M4: Font = .custom(appFontFamily, size: 16).weight(.medium)
    
    /// Quicksand Medium, 18pt
    static let M5: Font = .custom(appFontFamily, size: 18).weight(.medium)
    
    /// Quicksand Medium, 20pt
    static let M6: Font = .custom(appFontFamily, size: 20).weight(.medium)
    
    /// Quicksand Medium, 22pt
    static let M7: Font = .custom(appFontFamily, size: 22).weight(.medium)
    
    /// Quicksand Medium, 24pt
    static let M8: Font = .custom(appFontFamily, size: 24).weight(.medium)

    // MARK: - Regular
    
    /// Quicksand Regular, 8pt
    static let R1: Font = .custom(appFontFamily, size: 8).weight(.regular)
    
    /// Quicksand Regular, 12pt
    static let R2: Font = .custom(appFontFamily, size: 12).weight(.regular)
    
    /// Quicksand Regular, 10pt
    static let R3: Font = .custom(appFontFamily, size: 10).weight(.regular)
    
    /// Quicksand Regular, 16pt
    static let R4: Font = .custom(appFontFamily, size: 16).weight(.regular)
    
    /// Quicksand Regular, 20pt
    static let R5: Font = .custom(appFontFamily, size: 20).weight(.regular)
    
    /// Quicksand Regular, 18pt
    static let R6: Font = .custom(appFontFamily, size: 18).weight(.regular)
    
    /// Quicksand Regular, 22pt
    static let R7: Font = .custom(appFontFamily, size: 22).weight(.regular)
}
