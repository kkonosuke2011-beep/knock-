//
//  Subject.swift
//  knockα
//
//  Created by konosuke kawata on 2026/07/04.
//

import Foundation
enum Subject: String, CaseIterable, Identifiable, Hashable {
    case math = "数学"
    case english = "英語"
    case japanese = "国語"
    case science = "理科"
    case social = "社会"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .math:     return "function"
        case .english:  return "text.book.closed"
        case .japanese: return "pencil.and.scribble"
        case .science:  return "flask"
        case .social:   return "globe.asia.australia"
        }
    }
}
