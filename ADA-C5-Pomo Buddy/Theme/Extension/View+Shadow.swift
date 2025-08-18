
import SwiftUI

extension View {
    /// Applies a pre-defined 'large' shadow style, composed of two shadow layers based on the Figma design.
    func shadowLG() -> some View {
        self
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
    }
}
