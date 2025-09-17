import SwiftUI
import SwiftData

struct AddWorkTypeView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerViewModel.self) private var viewModel
    
    // 1. 부모 뷰의 상태를 제어하기 위한 Binding 변수
    @Binding var currentState: WorkTypeModalView.ModalState
    
    // UI 레이아웃을 위한 최소한의 State 변수
    @State private var presetName: String = ""
    @State private var focusTime: Int = 25
    @State private var breakTime: Int = 5

    // 이름이 비어있는지 확인하는 계산 프로퍼티
    private var isNameEmpty: Bool {
        presetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("workTypeModalView_text_createNewWork")
                .font(.R7)
                .padding(.bottom, 33)
            
            nameSection()
                .padding(.bottom, 47)

            timePickerSection()
                .padding(.bottom, 52)

            saveButton()
        }
    }
}

// MARK: - Subviews
private extension AddWorkTypeView {
    
    func nameSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("workTypeModalView_text_workName")
                .font(.R6)
            
            TextField("workTypeModalView_text_enterWorkName", text: $presetName)
                .font(.R4)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.grey50)
                )
                .foregroundColor(.caption1)
        }
    }
    
    func timePickerSection() -> some View {
        VStack(spacing: 28) {
            timePickerRow(
                title: "workTypeModalView_text_focusTime"
                , time: $focusTime
                , color: Color(hex: "#C7AA04")
                , min: 1
                , max: 60
            )
            timePickerRow(
                title: "workTypeModalView_text_breakTime"
                , time: $breakTime
                , color: Color(hex: "#2763BC")
                , min: 1
                , max: 30
            )
        }
    }
    
    func timePickerRow(
        title: LocalizedStringKey
        , time: Binding<Int>
        , color: Color
        , min: Int
        , max: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.R6)
                .foregroundColor(color)
            
            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(time.wrappedValue)")
                        .font(.B1)
                    Text("workTypeModalView_text_min")
                        .font(.M3)
                }
                
                Spacer()
                
                HStack(spacing: 0) {
                    Button {
                        if time.wrappedValue > min {
                            time.wrappedValue -= 1
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                    }
                    .frame(width: 54, height: 35)
                    .contentShape(Rectangle())
                    
                    Divider()
                        .frame(width: 2, height: 20)
                        .background(Color.toggle)
                    
                    Button {
                        if time.wrappedValue < max {
                            time.wrappedValue += 1
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                    }
                    .frame(width: 54, height: 35)
                    .contentShape(Rectangle())
                }
                .background(Color.grey50)
                .cornerRadius(8.4)
            }
        }
    }
    
    func saveButton() -> some View {
        Button {
            guard !isNameEmpty else { return }
            
            viewModel.addWorkType(
                name: presetName,
                focusMinutes: focusTime,
                breakMinutes: breakTime
            )
            
            currentState = .showingList
            
        } label: {
            Text("workTypeModalView_text_save")
                .font(.SB1)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(isNameEmpty ? .inactive : .secondary)
        .disabled(isNameEmpty)
    }
}


#Preview {
    ZStack {
        Color.black.opacity(0.2).ignoresSafeArea()
        // 4. 프리뷰가 정상 동작하도록 .constant 바인딩 제공
        AddWorkTypeView(currentState: .constant(.addingNew))
            .padding(.horizontal, 12)
    }
}
