import MultipeerConnectivity

extension NetworkManager: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
            //TODO: Tell the user something went wrong and try again
        log.error("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        log.info("ServiceBrowser found peer: \(peerID)")
        // Add the peer to the list of available peers
        Task { @MainActor in
            guard !availablePeers.contains(peerID) else { return }
            availablePeers.append(peerID)
        }
    }
    
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        log.info("ServiceBrowser lost peer: \(peerID)")
        // Remove lost peer from list of available peers
        Task { @MainActor in
            availablePeers.removeAll { $0 == peerID }
        }
    }
}
