import SwiftUI

struct WorkTypeEditView: View {
    @Binding var workType: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField(LocalizedStringKey("workTypeEditView_placeholder"), text: $workType)
                    .padding()
                    .background(AppColor.gray100)
                    .cornerRadius(12)
                
                Button(action: { dismiss() }) {
                    Text("workTypeEditView_button_done")
                }
                .buttonStyle(.primary)
                
                Spacer()
            }
            .padding()
            .navigationTitle(LocalizedStringKey("workTypeEditView_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("workTypeEditView_button_cancel")) { dismiss() }
                }
            }
        }
    }
}
