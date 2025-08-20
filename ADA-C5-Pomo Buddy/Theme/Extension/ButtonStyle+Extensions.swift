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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppFont.textXl, weight: .medium))
            .foregroundStyle(foregroundColor)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(Capsule())
            .shadowLG()
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static var yellow: CustomButtonStyle {
        CustomButtonStyle(
            backgroundColor: AppColor.yellow400,
            foregroundColor: AppColor.yellow900
        )
    }

    static var red: CustomButtonStyle {
        CustomButtonStyle(
            backgroundColor: AppColor.red400,
            foregroundColor: AppColor.red900
        )
    }
    
    static var green: CustomButtonStyle {
        CustomButtonStyle(
            backgroundColor: AppColor.lime300,
            foregroundColor: AppColor.lime800
        )
    }
}
