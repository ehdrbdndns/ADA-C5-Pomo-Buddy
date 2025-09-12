import SwiftUI

struct SettingsView: View {
    let CIRCLE_WIDTH: CGFloat = 728
    let CIRCLE_HEIGHT: CGFloat = 613
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                backgroundCircle(geometry: geometry)
                
                VStack(spacing: 0) {
                    characterContainer(geometry: geometry)
                    
                    supportLinks()
                }
            }
        }
    }
}

private extension SettingsView {
    func backgroundCircle(geometry: GeometryProxy) -> some View {
        Ellipse()
             .fill(Color.yellowDim20)
             .frame(width: CIRCLE_WIDTH, height: CIRCLE_HEIGHT)
             .position(x: geometry.size.width / 2, y: geometry.size.height / 10)
    }
    
    func characterContainer(geometry: GeometryProxy) -> some View {
        VStack {
            Text("navigation_settings")
                .font(.M8)
                .padding(.top, 40)
            
            Spacer()
            
            Image("hamster-idle")
                .resizable()
                .scaledToFit()
                .frame(height: 173)
                .padding(.bottom, 12)
            
            VStack {
                Text("BBOMO")
                    .font(.M4)
                    .foregroundStyle(Color.title)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.yellow1)
            )
            
            Spacer()
        }
        .frame(height: (CIRCLE_HEIGHT / 2) + geometry.size.height / 10)
    }
    
    func supportLinks() -> some View {
        List {
            Section() {
                Link(destination: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeJJmyNucC1Sf6Yfmms8WKyQztOslFEnHCudnDbQZQDyg2FFA/viewform?usp=dialog")!) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundStyle(Color.title)
                        Text("settings_button_contact_us")
                            .font(.R6)
                            .foregroundStyle(Color.title)
                    }
                }

                Link(destination: URL(string: "https://sunny-book-517.notion.site/26c748b531d080ba8860e7f2221956e6")!) {
                    HStack {
                        Image(systemName: "shield")
                            .foregroundStyle(Color.title)
                        Text("settings_button_privacy_policy")
                            .font(.R6)
                            .foregroundStyle(Color.title)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.grey50)
                .stroke(Color.grey30)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 35)
        .listStyle(.insetGrouped)
        .scrollDisabled(true)
    }
}
