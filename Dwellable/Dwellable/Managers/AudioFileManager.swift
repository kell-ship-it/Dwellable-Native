import Foundation
import AVFoundation

/// Manages local audio file storage for moments.
/// Saves audio recordings to Documents and retrieves them for playback.
class AudioFileManager {
    static let shared = AudioFileManager()

    private let fileManager = FileManager.default
    private let audioFolderName = "DwellableAudio"

    // MARK: - Setup

    private func getAudioFolder() -> URL {
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = docDir.appendingPathComponent(audioFolderName)

        // Create folder if it doesn't exist
        if !fileManager.fileExists(atPath: audioDir.path) {
            do {
                try fileManager.createDirectory(at: audioDir, withIntermediateDirectories: true)
                print("📁 [AUDIO] Created audio folder: \(audioDir.path)")
            } catch {
                print("❌ [AUDIO] Failed to create audio folder: \(error.localizedDescription)")
            }
        }

        return audioDir
    }

    // MARK: - Save Audio

    /// Save audio file from temporary location to permanent storage.
    /// - Parameter sourceURL: Temporary audio file URL (from AVAudioRecorder)
    /// - Returns: Filename if successful, nil if failed
    func saveAudio(from sourceURL: URL) -> String? {
        let audioFolder = getAudioFolder()
        let fileName = "moment_\(UUID().uuidString).m4a"
        let destinationURL = audioFolder.appendingPathComponent(fileName)

        do {
            // Copy from temp to permanent location
            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            let fileSizeKB = (try? fileManager.attributesOfItem(atPath: destinationURL.path))?[.size] as? Int ?? 0
            let sizeFormatted = String(format: "%.1f", Double(fileSizeKB) / 1024.0)

            print("✅ [AUDIO] Saved audio: \(fileName) (\(sizeFormatted) KB)")
            return fileName
        } catch {
            print("❌ [AUDIO] Failed to save audio: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Load Audio

    /// Get the URL for an audio file by filename.
    /// - Parameter fileName: Filename (e.g., "moment_12345.m4a")
    /// - Returns: File URL if exists, nil otherwise
    func getAudioURL(for fileName: String) -> URL? {
        let audioFolder = getAudioFolder()
        let fileURL = audioFolder.appendingPathComponent(fileName)

        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }

        print("⚠️ [AUDIO] Audio file not found: \(fileName)")
        return nil
    }

    // MARK: - Delete Audio

    /// Delete an audio file (optional cleanup).
    /// - Parameter fileName: Filename to delete
    func deleteAudio(fileName: String) {
        let audioFolder = getAudioFolder()
        let fileURL = audioFolder.appendingPathComponent(fileName)

        do {
            try fileManager.removeItem(at: fileURL)
            print("🗑️ [AUDIO] Deleted audio: \(fileName)")
        } catch {
            print("⚠️ [AUDIO] Failed to delete audio: \(error.localizedDescription)")
        }
    }

    // MARK: - Utility

    /// Get list of all saved audio files (for debugging).
    func getAllAudioFiles() -> [String] {
        let audioFolder = getAudioFolder()

        do {
            let files = try fileManager.contentsOfDirectory(atPath: audioFolder.path)
            return files.filter { $0.hasSuffix(".m4a") }
        } catch {
            print("⚠️ [AUDIO] Failed to list audio files: \(error.localizedDescription)")
            return []
        }
    }
}
