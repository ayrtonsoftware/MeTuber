//
//  String+Extensions.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//

import UIKit

extension String {
    static func loadEmbeddedFile(filename: String, ext: String) -> String? {
        if let filePath = Bundle.main.path(forResource: filename, ofType: ext) {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
               return fileContents
            } catch {
                print("Error reading file: \(error)")
            }
        } else {
            print("File not found")
        }
        return nil
    }
}
