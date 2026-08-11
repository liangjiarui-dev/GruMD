import Foundation

/// Watches a single file for external content changes (mtime / write).
final class FileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: CInt = -1
    private let queue = DispatchQueue(label: "com.grumd.filewatcher", qos: .utility)
    private var ignoreUntil: Date?

    /// Call after our own save so we don't treat it as an external edit.
    func ignoreEvents(for interval: TimeInterval = 0.8) {
        ignoreUntil = Date().addingTimeInterval(interval)
    }

    func stop() {
        source?.cancel()
        source = nil
        if fileDescriptor >= 0 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
    }

    func watch(url: URL, onChange: @escaping () -> Void) {
        stop()

        let path = url.path
        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .extend, .attrib, .rename, .delete],
            queue: queue
        )

        src.setEventHandler { [weak self] in
            guard let self else { return }
            if let until = self.ignoreUntil, Date() < until {
                return
            }
            let flags = src.data
            if flags.contains(.delete) || flags.contains(.rename) {
                // File replaced (common atomic save): re-arm on next bind from UI.
                DispatchQueue.main.async { onChange() }
                return
            }
            DispatchQueue.main.async { onChange() }
        }

        src.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        source = src
        src.resume()
    }

    deinit {
        stop()
    }
}
