import Foundation
import SwiftUI
import MultipeerConnectivity
import RealityKit
import os

protocol NetworkManagerDelegate: AnyObject {
    func didReceivePlayers(_ players: [Player])
    func didReceiveGameInfo(_ gameInfo: GameInfo)
}

@MainActor @Observable
final class NetworkManager: NSObject {
    private static let serviceType = "arElemental"

    private let myPeerID: MCPeerID
    private let startTime = Date().timeIntervalSince1970

    private var session: MCSession
    @ObservationIgnored
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    @ObservationIgnored
    private var serviceBrowser: MCNearbyServiceBrowser
    @ObservationIgnored
    var myName: String { myPeerID.displayName }

    let log = Logger()

    var connectedPlayers: [MCPeerID] = []
    var availablePeers: [MCPeerID] = []
    var recvdInviteFrom: MCPeerID?
    var recvdInvite = false
    var invitationHandler: ((Bool, MCSession?) -> Void)?

    var isPlayingGame = false

    weak var delegate: NetworkManagerDelegate?

    init (name: String? = nil) {
        myPeerID = MCPeerID(displayName: name ?? UIDevice.current.name)
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

    func sendPLayerList(_ players: [Player]) {
        let encoder = JSONEncoder()
        do {
            let stateData = try encoder.encode(players)
            sendToAllPeers(stateData)
        } catch let err {
            print(err)
        }
    }

    func sendGameInfo(_ info: GameInfo) {
        let encoder = JSONEncoder()
        do {
            let stateData = try encoder.encode(info)
            sendToAllPeers(stateData)
        } catch let err {
            print(err)
        }
    }

    func sendGameStarted() {
        let startString = "start"
        guard let stringData = startString.data(using: .ascii) else {
            return
        }
        sendToAllPeers(stringData)
    }

    func isMyPeerID(_ peerID: MCPeerID) -> Bool {
        myPeerID == peerID
    }

    private func sendToAllPeers(_ data: Data) {
            // Send data to another peer.
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
}
