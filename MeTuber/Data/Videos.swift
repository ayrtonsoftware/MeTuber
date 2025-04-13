//
//  Videos.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let videos = try? JSONDecoder().decode(Videos.self, from: jsonData)

import AVFoundation
import Foundation

// MARK: - Videos

struct Videos: Codable {
    let videos: [Video]
}

// MARK: - Video

struct Video: Codable {
    let id, authorID, description: String
    let video: String
    let thumbnailURL, zeroFrame: String
    let previewURL: String
    var item: AVPlayerItem?
    var isPreloaded: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case authorID = "authorId"
        case description, video, thumbnailURL, zeroFrame, previewURL
    }
}
