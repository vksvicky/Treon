//
//  CustomNotificationView.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import SwiftUI
import OSLog

struct CustomNotificationView: View {
    let notification: AppNotification
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Main notification content
            VStack(spacing: 16) {
                // Header with icon and title
                HStack(spacing: 12) {
                    Image(systemName: notification.type.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(notification.type.iconColor)
                        .frame(width: 24, height: 24)

                    Text(notification.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 20, height: 20)
                }

                // Message
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Actions
                if notification.primaryAction != nil || notification.secondaryAction != nil {
                    HStack(spacing: 12) {
                        if let secondaryAction = notification.secondaryAction {
                            Button(action: {
                                secondaryAction.action()
                                onDismiss()
                            }) {
                                Text(secondaryAction.title)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }

                        Spacer()

                        if let primaryAction = notification.primaryAction {
                            Button(action: {
                                primaryAction.action()
                                onDismiss()
                            }) {
                                Text(primaryAction.title)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .frame(maxWidth: 400)
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack {
        Spacer()

        CustomNotificationView(
            notification: AppNotification(
                type: .permission,
                title: "File Access Permission Required",
                message: "Treon needs permission to access files on your system. This is required to open files from Recent Files.",
                primaryAction: NotificationAction(
                    title: "Grant Permission",
                    action: { print("Grant Permission") },
                    style: .primary
                ),
                secondaryAction: NotificationAction(
                    title: "Reject",
                    action: { print("Reject") },
                    style: .secondary
                )
            ),
            onDismiss: { print("Dismiss") }
        )

        Spacer()
    }
    .background(Color(NSColor.controlBackgroundColor))
}
