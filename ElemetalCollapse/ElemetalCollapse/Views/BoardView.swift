import SwiftUI
import RealityKit

struct BoardView: View {
    @State var viewModel: BoardViewModel

    var body: some View {
        BoardARViewContainer(viewModel: $viewModel)
            .edgesIgnoringSafeArea(.all)
            .overlay {
                if viewModel.isHostGame || viewModel.gameInfo.GameState == .isPlaying {
                    makeOverlayView()
                } else {
                    makeLoadingView()
                }
            }
    }

    func makeLoadingView() -> some View {
        VStack {
            Spacer()

            ProgressView(
                label: {
                    Text("Waiting for host player to anchor the board...")
                        .padding()
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            )
            .padding(16)

            Spacer()
        }
        .background(Color.black.opacity(0.7))
    }

    func makeOverlayView() -> some View {
        VStack {
            HStack {
                Text(viewModel.message)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.players) { player in
                        Text("\(player.name) - Score: \(player.score)")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(player.turnPosition == viewModel.gameInfo.playerTurn ? .turnOn : .turnOff))
                    }
                }

                Spacer()
            }

            Spacer()
            if viewModel.verifyIsMyTurn() {
                Button {
                    viewModel.isPieceSelected = true
                } label: {
                    Text("Select the piece to play")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.primaryDomix)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    BoardView(
        viewModel: BoardViewModel(
            gameNetwork: NetworkManager(),
            state: .tutorial, gameInfo: GameInfo(playerTurn: 0, GameState: .gameStart, score: 0)
        )
    )
}
