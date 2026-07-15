import SwiftUI
import UIKit

enum AppColors {
    static let accent      = Color.accentColor
    static let background  = Color(uiColor: .systemBackground)
    static let surface     = Color(uiColor: .secondarySystemBackground)
    static let textPrimary = Color(uiColor: .label)
    static let textMuted   = Color(uiColor: .secondaryLabel)
    static let divider     = Color(uiColor: .separator)

    static let fieldColors: [Color] = [
        .red, .orange, .yellow, .green, .mint,
        .teal, .blue, .indigo, .purple, .pink,
        .black, .white, .gray
    ]
}
