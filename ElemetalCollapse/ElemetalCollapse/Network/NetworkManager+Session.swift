import MultipeerConnectivity

extension NetworkManager: MCSessionDelegate {
    nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case .notConnected:
            log.info("peer \(peerID) notConnected")
                // Peer disconnected, start accepting invitaions again
//            Task { @MainActor in
//                serviceAdvertiser.startAdvertisingPeer()
//            }

        case .connected:
            log.info("peer \(peerID) connected")
            Task { @MainActor in
                connectedPlayers = session.connectedPeers
            }

                // We are paired, stop accepting invitations
//            Task { @MainActor in
//                if connectedPeers.count == 4 {
//                    serviceAdvertiser.stopAdvertisingPeer()
//                }
//            }
        default:
            log.info("peer \(peerID) default")
                // Peer connecting or something else
            break
        }

    }
    
    nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
//        if let receivedString = String(data: data, encoding: .ascii) {
//            switch receivedString {
//            case "hostTableAdded" :
//
//                    // [Guest]
//                hostTableAdded()
//
//            case "guestTableAdded" :
//                    // [Host] The table shared with the guest.
//                model.tableAddedInGuestDevice = true
//                delegate?.modelChanged(model: model)
//                    // Game start
//                setupMultiPlayersGame()
//            default:
//                break
//            }
//
//        }
//
//
//
//        let decoder = JSONDecoder()
//        if let receivedState = try?  decoder.decode(GameState.self, from: data) {
//            didReceiveGameState(state: receivedState)
//        }

    }
    
    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        log.error("Receiving streams is not supported")
    }
    
    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        log.error("Receiving resources is not supported")
    }
    
    nonisolated func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {
        log.error("Receiving resources is not supported")
    }

    nonisolated func session(
        _ session: MCSession,
        didReceiveCertificate certificate: [Any]?,
        fromPeer peerID: MCPeerID,
        certificateHandler: @escaping (Bool) -> Void
    ) {
        certificateHandler(true)
    }
}
