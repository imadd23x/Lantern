import Foundation
import Darwin

/// Exact-byte optimistic concurrency plus an advisory lock for other Lantern writers.
/// Same-directory rename is atomic; a non-cooperating editor can still race the final check.
public enum ConfigurationTransaction {
    @discardableResult
    public static func apply(_ preview: ConfigurationPreview, to url: URL) throws -> URL? {
        let fm = FileManager.default
        let parent = url.deletingLastPathComponent()
        try fm.createDirectory(at: parent, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        var parentInfo = stat()
        guard lstat(parent.path, &parentInfo) == 0, (parentInfo.st_mode & S_IFMT) == S_IFDIR,
              parentInfo.st_uid == getuid() else { throw ConfigurationError.unsafeTarget }
        let lockURL = parent.appendingPathComponent(".lantern-config.lock")
        let fd = open(lockURL.path, O_CREAT | O_RDWR | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC, 0o600)
        guard fd >= 0 else { throw ConfigurationError.unsafeTarget }
        defer { flock(fd, LOCK_UN); close(fd) }
        var lockInfo = stat()
        guard fstat(fd, &lockInfo) == 0, (lockInfo.st_mode & S_IFMT) == S_IFREG,
              lockInfo.st_uid == getuid() else { throw ConfigurationError.unsafeTarget }
        guard flock(fd, LOCK_EX) == 0 else { throw ConfigurationError.unsafeTarget }
        try check(preview.original, at: url)
        var backup: URL?
        if let original = preview.original {
            let path = parent.appendingPathComponent(url.lastPathComponent + ".lantern-backup-" + UUID().uuidString)
            let backupFD = open(path.path, O_CREAT | O_EXCL | O_WRONLY | O_NOFOLLOW, 0o600)
            guard backupFD >= 0 else { throw ConfigurationError.backupFailed }
            let handle = FileHandle(fileDescriptor: backupFD, closeOnDealloc: true)
            do {
                try handle.write(contentsOf: original)
                try handle.synchronize()
                try handle.close()
                guard try Data(contentsOf: path) == original else { throw ConfigurationError.backupFailed }
            } catch { throw ConfigurationError.backupFailed }
            backup = path
        }
        let temporary = parent.appendingPathComponent(".lantern-" + UUID().uuidString)
        defer { try? fm.removeItem(at: temporary) }
        let temporaryFD = open(temporary.path, O_CREAT | O_EXCL | O_WRONLY | O_NOFOLLOW, 0o600)
        guard temporaryFD >= 0 else { throw ConfigurationError.unsafeTarget }
        let temporaryHandle = FileHandle(fileDescriptor: temporaryFD, closeOnDealloc: true)
        try temporaryHandle.write(contentsOf: preview.updated)
        try temporaryHandle.synchronize()
        try temporaryHandle.close()
        try check(preview.original, at: url)
        guard rename(temporary.path, url.path) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        return backup
    }

    public static func read(_ url: URL) throws -> Data? {
        let fd = open(url.path, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
        if fd < 0 {
            if errno == ENOENT { return nil }
            throw ConfigurationError.unsafeTarget
        }
        let handle = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
        defer { try? handle.close() }
        var info = stat()
        guard fstat(fd, &info) == 0 else { throw ConfigurationError.unsafeTarget }
        guard (info.st_mode & S_IFMT) == S_IFREG, info.st_uid == getuid(), info.st_size <= 2_000_000 else { throw ConfigurationError.unsafeTarget }
        let data = try handle.read(upToCount: 2_000_001) ?? Data()
        guard data.count <= 2_000_000 else { throw ConfigurationError.unsafeTarget }
        return data
    }

    private static func check(_ original: Data?, at url: URL) throws {
        guard try read(url) == original else { throw ConfigurationError.changed }
    }
}
