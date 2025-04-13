//
//  DownloadManager.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//

import Foundation

protocol IDownloadManager {
    func download(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

class DownloadManager: IDownloadManager {
    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1 // Serial queue
        queue.qualityOfService = .userInitiated
        return queue
    }()

    func download(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let operation = DownloadOperation(url: url) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        downloadQueue.addOperation(operation)
    }
}

class DownloadOperation: Operation {
    private let url: URL
    private let completion: (Result<Data, Error>) -> Void
    private var task: URLSessionDataTask?

    init(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        self.url = url
        self.completion = completion
        super.init()
    }

    override func main() {
        guard !isCancelled else { return }

        let semaphore = DispatchSemaphore(value: 0)

        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { semaphore.signal() }

            guard let self = self, !self.isCancelled else { return }

            if let error = error {
                self.completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ... 299).contains(httpResponse.statusCode)
            else {
                self.completion(.failure(NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            guard let data = data else {
                self.completion(.failure(NSError(domain: "DownloadError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            self.completion(.success(data))
        }

        task?.resume()
        semaphore.wait()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
