import SwiftUI
import RealityKit

struct BoardView: View {
    @State var viewModel: BoardViewModel

    var body: some View {

    BoardARViewContainer(viewModel: $viewModel)
        .edgesIgnoringSafeArea(.all)
        .overlay {
            VStack {
                viewModel.myAvatar
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .clipShape(Circle())

                Text(viewModel.message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top, .horizontal], 16)

                Spacer()

                if viewModel.state == .game {
                    viewModel.otherAvatar
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    BoardView(
        viewModel: BoardViewModel(
            gameNetwork: NetworkManager(),
            state: .tutorial
        )
    )
}
