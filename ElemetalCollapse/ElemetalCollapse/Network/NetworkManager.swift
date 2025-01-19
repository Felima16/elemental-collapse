import Foundation
import SwiftUI
import MultipeerConnectivity
import RealityKit
import os

@MainActor @Observable
final class NetworkManager: NSObject {
    private static let serviceType = "arElemental"

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let startTime = Date().timeIntervalSince1970

    private var session: MCSession
    @ObservationIgnored
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    @ObservationIgnored
    private var serviceBrowser: MCNearbyServiceBrowser

    let log = Logger()

    var connectedPlayers: [MCPeerID] = []
    var availablePeers: [MCPeerID] = []
    var recvdInviteFrom: MCPeerID?
    var recvdInvite = false
    var invitationHandler: ((Bool, MCSession?) -> Void)?

    var isPlayingGame = false

    override init () {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: NetworkManager.serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: NetworkManager.serviceType)

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }

    func startAdvertising() {
        serviceAdvertiser.startAdvertisingPeer()
    }

    func startBrowsing() {
        serviceBrowser.startBrowsingForPeers()
    }

    nonisolated func stopAdvertising() {
        Task { @MainActor in
            serviceAdvertiser.stopAdvertisingPeer()
            availablePeers.removeAll()
        }
    }

    nonisolated func stopBrowsing() {
        Task { @MainActor in
            serviceBrowser.stopBrowsingForPeers()
        }
    }

    func startSynchronizationService() throws -> MultipeerConnectivityService {
        try .init(session: session)
    }

    func sendInvitationToPeer(_ peer: MCPeerID) {
        serviceBrowser.invitePeer(
            peer,
            to: session,
            withContext: nil,
            timeout: 30
        )
    }

    func sendInvitationAwser(_ accepted: Bool) {
        invitationHandler?(accepted, accepted ? session : nil)
    }
}
