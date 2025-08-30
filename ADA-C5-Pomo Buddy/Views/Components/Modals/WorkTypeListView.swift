
import SwiftUI

struct WorkTypeListView: View {
    // 1. 부모 뷰의 상태를 제어하기 위한 Binding 변수
    @Binding var currentState: WorkTypeModalView.ModalState
    
    // autoTimerView가 사용하는 State 변수도 함께 이전
    @State private var isAutoTimerOn = false

    var body: some View {
        VStack {
            Text("workTypeModalView_text_selectWorkType")
                .font(.R7)
                .padding(.bottom, 33)
            
            galleryView()
                .padding(.bottom, 22)
            
            autoTimerView()
        }
    }
}

extension WorkTypeListView {
    func galleryView() -> some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                workCellView(
                    content: "Coding",
                    caption: "40min/10min",
                    isSelected: true
                )
                workCellView(
                    content: "Coding",
                    caption: "40min/10min",
                    isSelected: false
                )
            }
            
            GridRow {
                workCellView(
                    content: "Coding",
                    caption: "40min/10min",
                    isSelected: false
                )
                workCellView(
                    content: "Coding",
                    caption: "40min/10min",
                    isSelected: false
                )
            }
            
            GridRow {
                makeCellButtonView()
            }
        }
    }
    
    func workCellView(
        content: String,
        caption: String,
        isSelected: Bool
    ) -> some View {
        VStack(spacing: 12) {
            Text(content)
                .font(.M4)
                .foregroundColor(.caption1)
            
            Text(caption)
                .font(.R3)
                .foregroundColor(.caption1)
        }
        .frame(maxWidth: .infinity, minHeight: 98)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? Color.yellowDim20 : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.yellow1 : Color.grey30, lineWidth: 1)
            
        )
    }
    
    func makeCellButtonView() -> some View {
        Button {
            // 2. 버튼을 누르면 부모 뷰의 상태를 .addingNew로 변경
            currentState = .addingNew
        } label: {
            VStack {
                Image(systemName: "plus")
                    .font(.system(size: 13))
                    .foregroundColor(Color.caption1)
            }
            .frame(maxWidth: .infinity, minHeight: 98)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.grey40)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        Color.grey30,
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [5, 3]
                        )
                    )
            )
        }
    }
    
    func autoTimerView() -> some View {
        HStack {
            Text("workTypeModalView_text_AutoTimer")
                .font(.R6)
                .foregroundColor(.black)

            Spacer()

            Toggle("", isOn: $isAutoTimerOn)
                .tint(Color(hex: "#5BDA30"))
        }
        .padding(.horizontal, 22)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.grey40)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.grey30, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.blackDim20.ignoresSafeArea()
        // 3. 프리뷰가 정상 동작하도록 .constant 바인딩 제공
        WorkTypeListView(currentState: .constant(.showingList))
            .padding()
    }
}
