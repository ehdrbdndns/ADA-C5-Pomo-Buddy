import SwiftUI

struct WorkTypeListView: View {
    @Environment(TimerViewModel.self) private var _viewModel
    
    @Binding var currentState: WorkTypeModalView.ModalState
    @State private var workTypeToDelete: WorkType?

    var body: some View {
        VStack {
            Text("workTypeModalView_text_selectWorkType")
                .font(.R7)
                .padding(.bottom, 33)
            
            galleryView()
                .padding(.bottom, 22)
            
            autoTimerView()
        }
        .alert(item: $workTypeToDelete) { workType in
            Alert(
                title: Text("workTypeListView_alert_delete_title"),
                message: Text(String(format: NSLocalizedString("workTypeListView_alert_delete_message", comment: ""), workType.name)),
                primaryButton: .destructive(Text("workTypeListView_alert_delete_confirm")) {
                    _viewModel.deleteWorkType(workType)
                },
                secondaryButton: .cancel(Text("workTypeListView_alert_delete_cancel"))
            )
        }
    }
}

extension WorkTypeListView {
    func galleryView() -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(_viewModel.settings?.workList ?? [], id: \.id) { workType in
                workCellView(
                    content: workType.name,
                    caption: "\(workType.focusDurationInMinutes)min / \(workType.breakDurationInMinutes)min",
                    isSelected: workType.id == _viewModel.workType?.id
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    _viewModel.workType = workType
                }
                .onLongPressGesture {
                    if _viewModel.workTypeList.count > 1 {
                        self.workTypeToDelete = workType
                    }
                }
            }
            
            if (_viewModel.workTypeList.count < 6) {
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
        @Bindable var viewModel = _viewModel
        
        return HStack {
            Text("workTypeModalView_text_AutoTimer")
                .font(.R6)
                .foregroundColor(.black)

            Spacer()

            Toggle("", isOn: $viewModel.isAutoTimerEnabled)
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
        WorkTypeListView(currentState: .constant(.showingList))
            .padding()
    }
}
