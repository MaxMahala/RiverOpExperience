import SwiftUI
import StoreKit

public struct Remote_FKConfigObject_sg: Codable, Hashable, Identifiable {
    public let id: String
    public let icon: String
    public let name: String
    public let secondsPerStep: Int
    public let steps: [String]
}

public struct ComdskgCodeRequest_ObjExcode: Codable, Hashable, Identifiable {
    public let id: String?
    public let title: String?
    public let synopsis: String?
    public let symbol: String?
    public let readMinutes: Int?
    public let tags: [String]?
    public let bodyMarkdown: String?
}

public struct FfkContent_mTool_FKkff: Codable, Hashable {
    public let dailyGoal: Int
    public let season: String?
    public let privacyUrl: String?
}

public struct MFMMSconsumeing_fmsgsg: Codable, Hashable {
    public let rituals: [Remote_FKConfigObject_sg]?
    public let tales: [ComdskgCodeRequest_ObjExcode]?
    public let config: FfkContent_mTool_FKkff?
}

public final class FKConfigure_FKfjjgsdgOptions_f4j35 {
    public static let init_FjdsghIo35242 = FKConfigure_FKfjjgsdgOptions_f4j35()

    private let remoteEndpointURL = URL(string: "https://riversxpapp.com/appconfig")!

    private let userDefaultsStorage = UserDefaults.standard
    private let userDefaultsPayloadKey = "RiverDExperience.remoteContentEnvelope.payload.v2"

    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()

    private let jsonEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.withoutEscapingSlashes]
        return e
    }()

    private init() {}

    @discardableResult
    public func fetchDecodeAndPersiJjjxjstRemoteContemxntEnvelope()
    async throws -> MFMMSconsumeing_fmsgsg {
        var request = URLRequest(url: remoteEndpointURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let raw = String(data: data, encoding: .utf8) {
        }

        let envelope = try decodeEnvelopeOrConfig(from: data)
        try persistDecodedEnvelopeToUserDefaults(envelope)
        return envelope
    }

    private func decodeEnvelopeOrConfig(from data: Data) throws -> MFMMSconsumeing_fmsgsg {
        if let env = try? jsonDecoder.decode(MFMMSconsumeing_fmsgsg.self, from: data),
           env.config != nil {
            return env
        }
        let cfg = try jsonDecoder.decode(FfkContent_mTool_FKkff.self, from: data)
        return MFMMSconsumeing_fmsgsg(rituals: nil, tales: nil, config: cfg)
    }

    public func loadPeevreventEnvelopeFromUserDefaults()
    -> MFMMSconsumeing_fmsgsg? {
        guard let data = userDefaultsStorage.data(forKey: userDefaultsPayloadKey) else { return nil }
        return try? jsonDecoder.decode(MFMMSconsumeing_fmsgsg.self, from: data)
    }

    public func loadCachedSeason() -> String? {
        guard let env = loadPeevreventEnvelopeFromUserDefaults() else { return nil }
        return env.config?.season
    }

    public func clearPersistedRemoteContentEnvelopeFromUserDefaults() {
        userDefaultsStorage.removeObject(forKey: userDefaultsPayloadKey)
    }

    private func persistDecodedEnvelopeToUserDefaults(_ envelope: MFMMSconsumeing_fmsgsg) throws {
        let data = try jsonEncoder.encode(envelope)
        userDefaultsStorage.set(data, forKey: userDefaultsPayloadKey)
    }
}
