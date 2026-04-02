//
//  SwipeToStartButton.swift
//  Layman
//

import SwiftUI

struct SwipeToStartButton: View {
    var title: String
    var onSwipeSuccess: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isSuccess = false
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbSize = geometry.size.height - 12
            // The maximum distance the thumb can travel
            let maxDrag = trackWidth - thumbSize - 12
            
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color(hex: "D86D3F")) // Brand Accent Orange
                
                // Centered Text
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    // Offset text slightly right so it's visually centered
                    .padding(.leading, thumbSize)
                
                // Draggable Thumb
                ZStack {
                    Circle()
                        .fill(.white)
                    
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "D86D3F"))
                }
                .frame(width: thumbSize, height: thumbSize)
                .padding(6)
                .offset(x: max(0, min(dragOffset, maxDrag)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isSuccess else { return }
                            if value.translation.width > 0 {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { _ in
                            guard !isSuccess else { return }
                            
                            // If user drags past 75%, consider it a success
                            if dragOffset > maxDrag * 0.75 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = maxDrag
                                }
                                triggerHapticSuccess()
                                isSuccess = true
                                
                                // Give the thumb animation time to finish before firing callback
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSwipeSuccess()
                                }
                            } else {
                                // Snap back
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    dragOffset = 0
                                }
                                triggerHapticImpact()
                            }
                        }
                )
            }
        }
        .frame(height: 60)
    }
    
    private func triggerHapticImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func triggerHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
