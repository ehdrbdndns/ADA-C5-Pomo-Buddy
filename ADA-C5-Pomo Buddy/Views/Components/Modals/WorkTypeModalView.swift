//
//  WorkTypeModal.swift
//  ADA-C5-Pomo Buddy
//
//  Created by Donggyun Yang on 8/30/25.
//
import SwiftUI

struct WorkTypeModalView: View {
    enum ModalState {
        case showingList
        case addingNew
    }
    @State private var currentState: ModalState = .showingList
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            header()
            
            switch currentState {
            case .showingList:
                WorkTypeListView(currentState: $currentState)
            case .addingNew:
                AddWorkTypeView(currentState: $currentState)
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        )
    }
}

extension WorkTypeModalView {
    func header() -> some View {
        HStack {
            Spacer()
            
            Button {
                isShowing = false
                currentState = .showingList
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.blackDim20.ignoresSafeArea()
        
        WorkTypeModalView(isShowing: .constant(true))
            .padding(.horizontal, 12)
    }
}
