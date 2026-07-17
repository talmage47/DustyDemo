import SwiftUI

/// Stylized stand-in for a real jersey design — the actual visual customizer
/// lands in Step 4. Renders a two-color card with the team name and optional
/// player number.
struct TeamDesignPreview: View {
    let team: Team
    let playerNumber: Int?
    var height: CGFloat = 240

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: team.primaryColorHex),
                    Color(hex: team.primaryColorHex).opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Diagonal secondary-color stripe as a design accent
            GeometryReader { geo in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height * 0.55))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.35))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.65))
                    path.addLine(to: CGPoint(x: 0, y: geo.size.height * 0.85))
                    path.closeSubpath()
                }
                .fill(Color(hex: team.secondaryColorHex).opacity(0.9))
            }

            VStack(spacing: 4) {
                Text(team.name.uppercased())
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
                if let number = playerNumber {
                    Text("\(number)")
                        .font(.system(size: 88, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 3)
                } else {
                    Image(systemName: "tshirt.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
