//
//  Data+Extensions.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//

import Foundation

extension Data {
    static func loadEmbeddedFile(filename: String, ext: String) -> Data? {
        if let filePath = Bundle.main.path(forResource: filename, ofType: ext) {
            do {
                let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                return fileData
            } catch {
                print("Error reading file: \(error)")
            }
        } else {
            print("File not found: \(filename).\(ext)")
        }
        return nil
    }
}
