//
//  LaunchScreenView.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @ScaledMetric(relativeTo: .title) private var ringSize: CGFloat = 120
    @ScaledMetric(relativeTo: .title) private var ringLineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Timer icon - minimalist circular design
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: ringLineWidth)
                        .frame(width: ringSize, height: ringSize)

                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            .red,
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                }

                // App name
                Text("Boxing Timer")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
