//
//  Typography.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

extension Font {
    // App title - large, bold, italic serif
    static let appTitle = Font.system(.title, design: .serif).weight(.bold).italic()

    // Post author name - medium-large serif
    static let postAuthor = Font.system(.title3, design: .serif).weight(.semibold)

    // Post body text - normal serif
    static let postBody = Font.system(.body, design: .serif)
}
