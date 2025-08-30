//
//  ButtonStyle+Extensions.swift
//  ADA-C5-Pomo Buddy
//
//  Created by Donggyun Yang on 8/19/25.
//


import SwiftUI

/// A custom button style that defines the basic appearance and interaction of all buttons in the app.
struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var borderColor: Color?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.SB1)
            .foregroundStyle(foregroundColor)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor ?? backgroundColor, lineWidth: 1)
            )
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static var primary: CustomButtonStyle {
        CustomButtonStyle(
            backgroundColor: Color.yellow1,
            foregroundColor: Color.yellow2
        )
    }
    
    static var secondary: CustomButtonStyle {
        CustomButtonStyle(
            backgroundColor: Color.yellowDim20,
            foregroundColor: Color.yellow2,
            borderColor: Color.yellow1
        )
    }
    
    static var inactive: CustomButtonStyle {
        CustomButtonStyle(
            backgroundColor: Color.greyDim50,
            foregroundColor: Color.grey20,
            borderColor: Color.grey10
        )
    }
}
