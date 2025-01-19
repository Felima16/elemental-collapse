import MultipeerConnectivity

extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        Task { @MainActor in
                // Tell PairView to show the invitation alert
            recvdInvite = true
                // Give PairView the peerID of the peer who invited us
            recvdInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
        log.info("didReceiveInvitationFromPeer \(peerID)")
    }

    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
}
