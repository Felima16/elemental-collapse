import SwiftUI

struct AvailablePlayersView: View {
    @State var viewModel: AvailablePlayersViewModel
    @Binding var showAvailableView: Bool

    var body: some View {
        VStack {
            List(viewModel.availablePlayers, id: \.self) { peer in
                Button(peer.displayName) {
                    viewModel.invatePeer(peer)
                }
            }
            HStack(spacing: 24) {
                Button("Cancel") {
                    showAvailableView = false
                }
                .buttonStyle(.borderedProminent)

                Button("Start Game") {
                    viewModel.gameNetwork.isPlayingGame = true
                }
//                .disabled(viewModel.gameNetwork.connectedPlayers.count < 1)
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
        }
        .alert("Received an invite from \(viewModel.gameNetwork.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $viewModel.gameNetwork.recvdInvite) {
            Button("Accept invite") {
                viewModel.gameNetwork.sendInvitationAwser(true)
            }
            Button("Reject invite") {
                viewModel.gameNetwork.sendInvitationAwser(false)
            }
        }
        .onAppear() {
            viewModel.gameNetwork.startBrowsing()
            viewModel.gameNetwork.startAdvertising()
        }
        .onDisappear() {
            viewModel.gameNetwork.stopBrowsing()
            viewModel.gameNetwork.stopAdvertising()
        }
        .fullScreenCover(isPresented: $viewModel.gameNetwork.isPlayingGame) {
            BoardView(
                viewModel: BoardViewModel(
                    gameNetwork: viewModel.gameNetwork,
                    state: .game
                )
            )
        }
    }
}
