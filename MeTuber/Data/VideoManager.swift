//
//  VideoManager.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//

protocol IVideoManager {
    var count: Int { get }
    var videos: [Video] { get }
    func getNext(offset: Int, count: Int) -> [Video]
    func getVideo(index: Int) -> Video?
    func getNext(video: Video) -> Video?
    func getPrevious(video: Video) -> Video?
}
