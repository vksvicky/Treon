import SwiftUI

// MARK: - Design System Constants (Deprecated - Use UIConstants instead)
struct DesignConstants {
    static let buttonWidth: CGFloat = UIConstants.buttonWidth
    static let buttonHeight: CGFloat = UIConstants.buttonHeight
    static let buttonCornerRadius: CGFloat = UIConstants.buttonCornerRadius
    static let buttonSpacing: CGFloat = UIConstants.buttonSpacing
    static let buttonFontSize: CGFloat = UIConstants.buttonFontSize
    static let buttonFontWeight: Font.Weight = UIConstants.buttonFontWeight
    static let hoverAnimationDuration: Double = UIConstants.hoverAnimationDuration
}

// MARK: - Custom Button Style
struct StandardButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let isOutlined: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: DesignConstants.buttonFontSize, weight: DesignConstants.buttonFontWeight))
            .foregroundColor(foregroundColor)
            .frame(width: DesignConstants.buttonWidth, height: DesignConstants.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.buttonCornerRadius)
                    .fill(isOutlined ? Color.clear : backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignConstants.buttonCornerRadius)
                            .stroke(backgroundColor, lineWidth: isOutlined ? 1 : 0)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


