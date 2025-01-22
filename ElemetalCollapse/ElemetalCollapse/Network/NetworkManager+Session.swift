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

        case .connected:
            log.info("peer \(peerID) connected")
            Task { @MainActor in
                connectedPlayers = session.connectedPeers
            }

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

        let decoder = JSONDecoder()

        if let receivedGameInfo = try? decoder.decode(GameInfo.self, from: data) {
            Task { @MainActor in
                if receivedGameInfo.GameState == .gameStart {
                    isPlayingGame = true
                }
            }

            Task {
                await delegate?.didReceiveGameInfo(receivedGameInfo)
            }
        }

        if let receivedPlayers = try? decoder.decode([Player].self, from: data) {
            Task {
                await delegate?.didReceivePlayers(receivedPlayers)
            }
        }

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
