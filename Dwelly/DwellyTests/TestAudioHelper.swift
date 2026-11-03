import Foundation

/// Helper class for loading test audio files during testing
class TestAudioHelper {
    /// Returns the URL of a test audio file
    /// - Parameters:
    ///   - duration: Duration in seconds (5, 10, 30, 60 for 1 hour, etc.)
    /// - Returns: URL to the test audio file if it exists
    static func testAudioURL(duration: Int) -> URL? {
        let testAssetName: String?

        switch duration {
        case 300: // 5 minutes
            testAssetName = "test_audio_5min"
        case 600: // 10 minutes
            testAssetName = "test_audio_10min"
        case 1800: // 30 minutes
            testAssetName = "test_audio_30min"
        case 3600: // 1 hour
            testAssetName = "test_audio_1hour"
        case 9000: // 2.5 hours (full)
            testAssetName = "test_audio_full"
        default:
            return nil
        }

        guard let assetName = testAssetName else { return nil }

        // Load from test bundle
        let testBundle = Bundle(for: self)
        guard let url = testBundle.url(forResource: assetName, withExtension: "m4a") else {
            print("⚠️ Test audio file not found: \(assetName).m4a")
            return nil
        }

        return url
    }

    /// Get all available test audio durations
    static var availableDurations: [Int] {
        return [300, 600, 1800, 3600, 9000]
    }

    /// Get human-readable label for duration
    static func label(for duration: Int) -> String {
        switch duration {
        case 300: return "5 minutes"
        case 600: return "10 minutes"
        case 1800: return "30 minutes"
        case 3600: return "1 hour"
        case 9000: return "2.5 hours"
        default: return "Unknown"
        }
    }
}
