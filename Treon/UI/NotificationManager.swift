import SwiftUI
import Combine
import OSLog

/// Manages custom notifications for the app
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var currentNotification: AppNotification?
    @Published var isShowingNotification = false

    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "NotificationManager")

    private init() {}

    func showNotification(_ notification: AppNotification) {
        logger.info("Showing notification: \(notification.title)")
        currentNotification = notification
        isShowingNotification = true

        // Auto-dismiss after duration if specified
        if let duration = notification.autoDismissDuration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.dismissNotification()
            }
        }
    }

    func dismissNotification() {
        logger.info("Dismissing notification")
        withAnimation(.easeInOut(duration: 0.3)) {
            isShowingNotification = false
        }

        // Clear notification after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentNotification = nil
        }
    }
}

/// Represents a custom app notification
struct AppNotification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let primaryAction: NotificationAction?
    let secondaryAction: NotificationAction?
    let autoDismissDuration: TimeInterval?

    init(
        type: NotificationType,
        title: String,
        message: String,
        primaryAction: NotificationAction? = nil,
        secondaryAction: NotificationAction? = nil,
        autoDismissDuration: TimeInterval? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.autoDismissDuration = autoDismissDuration
    }
}

enum NotificationType {
    case permission
    case error
    case success
    case info

    var iconName: String {
        switch self {
        case .permission:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .permission:
            return .orange
        case .error:
            return .red
        case .success:
            return .green
        case .info:
            return .blue
        }
    }
}

struct NotificationAction {
    let title: String
    let action: () -> Void
    let style: ActionStyle

    enum ActionStyle {
        case primary
        case secondary
    }
}
