import Foundation

enum Config {
    /// Same backend as HomeBuddy (healthbuddy-vm behind the Cloudflare tunnel).
    static let baseURL: URL = {
        #if DEBUG
        // Local testing: SIMCTL_CHILD_HB_BASE_URL=http://127.0.0.1:8001
        if let s = ProcessInfo.processInfo.environment["HB_BASE_URL"], let url = URL(string: s) { return url }
        #endif
        return URL(string: "https://rakesh.ashunya.com")!
    }()
}
