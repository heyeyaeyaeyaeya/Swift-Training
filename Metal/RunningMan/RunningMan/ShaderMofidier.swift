//
//  ShaderMofidier.swift
//  RunningMan
//
//  Created by Sergey Leontiev on 19. 1. 2026..
//

import SwiftUI

struct ShaderMofidier: ViewModifier {
    let shaderType: ShaderType
    let startDate = Date()
    
    func body(content: Content) -> some View {
        switch shaderType {
        case .board:
            content.colorEffect(ShaderLibrary.checkerboard(.float(10), .color(.blue)))
        case .noise:
            TimelineView(.animation) { context in
                content.colorEffect(ShaderLibrary.noise(.float(startDate.timeIntervalSinceNow)))
            }
        case .pixellate:
            content.layerEffect(ShaderLibrary.pixellate(.float(10)), maxSampleOffset: .zero)
        case .simplewave:
            TimelineView(.animation) { context in
                content.visualEffect { content, proxy in
                    content
                        .distortionEffect(ShaderLibrary.complexWave(
                            .float(startDate.timeIntervalSinceNow),
                            .float2(proxy.size),
                            .float(0.5),
                            .float(8),
                            .float(10)
                        ), maxSampleOffset: .zero)
                }
            }
        }
    }
}
