//
//  WatchViewModel.swift
//  CatsWatch Watch App
//
//  Created by Alberto on 07/06/24.
//

import SwiftUI
import WatchConnectivity
import Combine

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var data: Data?
    private let userDefaults = UserDefaults.standard
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        loadCachedData()
    }
    
    func fetchRandomCat(bypassCache: Bool = false) {
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        if bypassCache == false, let lastFetchedDate = userDefaults.object(forKey: "lastFetchedDate") as? Date,
           lastFetchedDate == currentDate,
           let cachedData = userDefaults.data(forKey: "cachedCatImage") {
            self.data = cachedData
        } else {
            Task {
                do {
                    let imageData = try await CatService.fetchRandomCat()
                    DispatchQueue.main.async {
                        self.data = imageData
                        self.cacheData(imageData, for: currentDate)
                    }
                } catch {
                    print("Failed to fetch image data: \(error)")
                }
            }
        }
    }
    
    private func loadCachedData() {
        let currentDate = Calendar.current.startOfDay(for: Date())
        if let lastFetchedDate = userDefaults.object(forKey: "lastFetchedDate") as? Date,
           lastFetchedDate == currentDate,
           let cachedData = userDefaults.data(forKey: "cachedCatImage") {
            self.data = cachedData
        }
    }
    
    private func cacheData(_ data: Data, for date: Date) {
        userDefaults.set(data, forKey: "cachedCatImage")
        userDefaults.set(date, forKey: "lastFetchedDate")
    }
    
    func catDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        
        let date = Date()
        return "Cat for \(formatter.string(from: date))"
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
