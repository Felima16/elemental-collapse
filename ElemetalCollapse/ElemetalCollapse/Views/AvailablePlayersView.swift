import SwiftUI

struct AvailablePlayersView: View {
    @State var viewModel: AvailablePlayersViewModel
    @Binding var showAvailableView: Bool

    var body: some View {
        VStack {
            Text("Lobby")
                .font(.title)

            List(viewModel.availablePlayers, id: \.self) { peer in
                Button {
                    viewModel.invatePeer(peer)
                } label: {
                    HStack {
                        Text(peer.displayName)
                            .font(.title3)
                            .padding(.vertical, 16)

                        Spacer()

                        if viewModel.verifyPeerConnection(peer) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            HStack(spacing: 24) {
                Button {
                    showAvailableView = false
                } label: {
                    Text("Cancel")
                        .font(.title3)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.primaryDomix))
                }

                Button {
                    viewModel.isHost = true
                    viewModel.starGame()
                } label: {
                    Text("Start Game")
                        .font(.title3)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.gameNetwork.connectedPlayers.count < 1 ? .gray : .primaryDomix)
                        )
                }
                .disabled(viewModel.gameNetwork.connectedPlayers.count < 1)
            }
            .foregroundStyle(.whiteDomix)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .alert(
            "Received an invite from \(viewModel.gameNetwork.recvdInviteFrom?.displayName ?? "ERR")!",
            isPresented: $viewModel.gameNetwork.recvdInvite
        ) {
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
                    state: .game,
                    isHostGame: viewModel.isHost,
                    gameInfo: viewModel.gameInfo
                )
            )
        }
    }
}
