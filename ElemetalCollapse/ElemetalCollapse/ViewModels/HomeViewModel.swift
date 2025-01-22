import SwiftUI

@Observable
final class HomeViewModel {
    var showPlayOptions = false
    var showAvailablePlayers = false
    var showAlertEditName = false

    var name = ""
    var alertTitle = "Enter your name"

    init() {
        if let savedName = UserDefaults.standard.string(forKey: "name-elemental-collapse") {
            name = savedName
        } else {
            showAlertEditName = true
            name = "Player"
        }
    }

    func saveName() {
        UserDefaults.standard.set(name, forKey: "name-elemental-collapse")
    }
}
