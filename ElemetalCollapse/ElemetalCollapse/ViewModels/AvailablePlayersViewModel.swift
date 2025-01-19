import SwiftUI
import MultipeerConnectivity

@MainActor @Observable
final class AvailablePlayersViewModel {
    var gameNetwork: NetworkManager

    init(gameNetwork: NetworkManager) {
        self.gameNetwork = gameNetwork
    }

    var availablePlayers: [MCPeerID] {
        gameNetwork.availablePeers
    }

    func invatePeer(_ peer: MCPeerID) {
        gameNetwork.sendInvitationToPeer(peer)
    }
}
