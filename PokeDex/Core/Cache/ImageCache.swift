import UIKit

actor ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    private var inFlightTasks: [URL: Task<UIImage, Error>] = [:]

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = caches.appendingPathComponent("PokeDexImageCache")
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        memoryCache.countLimit = 150
    }

    func fetchImage(for url: URL) async throws -> UIImage {
        if let cached = cachedImage(for: url) { return cached }

        if let existing = inFlightTasks[url] {
            return try await existing.value
        }

        let task = Task<UIImage, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            await store(image, for: url)
            return image
        }

        inFlightTasks[url] = task
        defer { inFlightTasks.removeValue(forKey: url) }
        return try await task.value
    }

    private func cachedImage(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        if let memory = memoryCache.object(forKey: key as NSString) {
            return memory
        }
        let fileURL = diskCacheURL.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
        return nil
    }

    private func store(_ image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString)
        let fileURL = diskCacheURL.appendingPathComponent(key)
        try? image.pngData()?.write(to: fileURL)
    }

    private func cacheKey(for url: URL) -> String {
        url.lastPathComponent
    }
}
