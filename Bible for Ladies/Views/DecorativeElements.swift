import SwiftUI

// MARK: - Top Decoration (Fixed in header area)
struct TopDecoration: View {
    let theme: ThemeColors
    
    var body: some View {
        ZStack {
            // Hearts cluster
            HeartShape()
                .fill(theme.primary.opacity(0.3))
                .frame(width: 45, height: 42)
                .offset(x: 15, y: 0)
                .rotationEffect(.degrees(-20))
            
            HeartShape()
                .fill(theme.primary.opacity(0.45))
                .frame(width: 30, height: 28)
                .offset(x: -10, y: 25)
                .rotationEffect(.degrees(15))
            
            HeartShape()
                .fill(theme.primary.opacity(0.25))
                .frame(width: 22, height: 20)
                .offset(x: 25, y: 40)
            
            // Tulips
            SimpleTulips(theme: theme)
                .offset(x: 5, y: 85)
        }
        .frame(width: 90, height: 150)
    }
}

// MARK: - Background with Decoration (for other pages)
struct DecoratedBackground: View {
    let theme: ThemeColors
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            theme.background
            
            TopDecoration(theme: theme)
                .padding(.trailing, 10)
                .padding(.top, 50)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Simple Tulips
struct SimpleTulips: View {
    let theme: ThemeColors
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            SingleTulip(color: theme.primary.opacity(0.5), height: 45)
                .rotationEffect(.degrees(-8))
            SingleTulip(color: theme.primary.opacity(0.7), height: 55)
            SingleTulip(color: theme.primary.opacity(0.4), height: 40)
                .rotationEffect(.degrees(10))
        }
    }
}

struct SingleTulip: View {
    let color: Color
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Flower head
            ZStack {
                Ellipse()
                    .fill(color)
                    .frame(width: 12, height: 18)
                    .offset(x: -4)
                    .rotationEffect(.degrees(-20))
                
                Ellipse()
                    .fill(color)
                    .frame(width: 12, height: 18)
                    .offset(x: 4)
                    .rotationEffect(.degrees(20))
                
                Ellipse()
                    .fill(color.opacity(0.8))
                    .frame(width: 10, height: 16)
                    .offset(y: -3)
            }
            
            // Stem
            Rectangle()
                .fill(color.opacity(0.5))
                .frame(width: 2, height: height * 0.5)
        }
        .frame(height: height)
    }
}

// MARK: - Heart Shape
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w/2, y: h))
        path.addCurve(
            to: CGPoint(x: 0, y: h/4),
            control1: CGPoint(x: w/2 - w/4, y: h*3/4),
            control2: CGPoint(x: 0, y: h/2)
        )
        path.addArc(center: CGPoint(x: w/4, y: h/4), radius: w/4,
                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: CGPoint(x: w*3/4, y: h/4), radius: w/4,
                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addCurve(
            to: CGPoint(x: w/2, y: h),
            control1: CGPoint(x: w, y: h/2),
            control2: CGPoint(x: w/2 + w/4, y: h*3/4)
        )
        return path
    }
}
