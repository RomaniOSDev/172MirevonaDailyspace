//
//  StudioContainerView.swift
//  172MirevonaDailyspace
//

import SwiftUI

struct StudioContainerView: View {
    @State private var segment = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $segment) {
                Text("History").tag(0)
                Text("Insights").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface.opacity(0.94), Color.appSurface.opacity(0.62)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Group {
                if segment == 0 {
                    PaletteHistoryView()
                } else {
                    PaletteInsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.3), value: segment)
        }
    }
}
