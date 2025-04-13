//
//  JsonVideoManager.swift
//  MeTuber
//
//  Created by Michael Bergamo on 4/12/25.
//

import Foundation

class JsonVideoManager: IVideoManager {
    private(set) var videos = [Video]()
    
    func getNext(offset: Int, count: Int) -> [Video] {
        print("JsonVideoManager: getNext offset: \(offset) count: \(count)")
        var items = [Video]()
        for vdx in offset..<offset+count {
            if vdx >= videos.count {
                break
            }
            items.append(videos[vdx])
        }
        return items
    }

    func getNext(video: Video) -> Video? {
        guard let index = videos.firstIndex(where: {$0.id == video.id}) else {
            return nil
        }
        return getVideo(index: index+1)
    }
    
    func getPrevious(video: Video) -> Video? {
        guard let index = videos.firstIndex(where: {$0.id == video.id}) else {
            return nil
        }
        return getVideo(index: index - 1)
    }

    var count: Int {
        print("JsonVideoManager: count is \(videos.count)")
        return videos.count
    }

    init() {
        print("JsonVideoManager: Initializing")
        guard let jsonStr = String.loadEmbeddedFile(filename: "Videos", ext: "json") else {
            print("JsonVideoManager: Failed to load embedded file")
            return
        }
        if let jsonData = jsonStr.data(using: .utf8) {
            if let items = try? JSONDecoder().decode(Videos.self, from: jsonData) {
                print("JsonVideoManager: Successfully loaded \(items.videos.count) videos")
                videos = items.videos
            } else {
                print("JsonVideoManager: Failed to decode JSON")
            }
        }
    }

    func getVideo(index: Int) -> Video? {
        if index > videos.count {
            getNext(offset: index, count: 3)
        }
        guard index >= 0 && index < count else {
            return nil
        }
        return videos[index]
    }
}
