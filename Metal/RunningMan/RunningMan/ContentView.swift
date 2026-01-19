//
//  ContentView.swift
//  RunningMan
//
//  Created by Sergey Leontiev on 19. 1. 2026..
//

import SwiftUI

struct ContentView: View {
    @State var shaderType: ShaderType = .board
    let startDate = Date()
    
    var body: some View {
        VStack {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 300))
                .modifier(ShaderMofidier(shaderType: shaderType))
            
            Picker("Shader", selection: $shaderType) {
                ForEach(ShaderType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ContentView()
}

enum ShaderType: String, CaseIterable, Identifiable {
    case board
    case noise
    case pixellate
    case simplewave
    
    var id: String { self.rawValue }
}
