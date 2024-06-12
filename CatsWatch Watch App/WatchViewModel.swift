//
//  WatchViewModel.swift
//  CatsWatch Watch App
//
//  Created by Alberto on 07/06/24.
//

import SwiftUI
import WatchConnectivity
import Combine
import SwiftData

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Environment(\.modelContext) var modelContext
    
    @Published var cat: Cat?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func fetchRandomCat() {
        Task {
            do {
                let fetchedCat = try await CatService.fetchRandomCat()
                DispatchQueue.main.async {
                    self.cat = fetchedCat
                }
            } catch {
                print("Failed to fetch cat: \(error)")
            }
        }
    }
    
    func openCatProfile() {
        guard WCSession.default.isReachable else { return }
        let message = ["action": "openCatProfile"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message: \(error.localizedDescription)")
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated with state: \(activationState.rawValue)")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("WCSession reachability changed to: \(session.isReachable)")
    }
}
