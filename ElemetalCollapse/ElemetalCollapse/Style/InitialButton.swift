import SwiftUI

struct InitialButton: ButtonStyle {
    @Binding var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.whiteDomix)
            .foregroundStyle(.pinkDomix)
            .clipShape(Capsule())
    }
}
