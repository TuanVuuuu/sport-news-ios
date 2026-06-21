import Foundation
import Pulse

enum NetworkSessionProvider {
    static let shared: URLSessionProtocol = URLSessionProxy(configuration: .default)
}
