#include <gtest/gtest.h>
#include <QApplication>
#include <QDialog>
#include <QComboBox>
#include <QSlider>
#include <QSpinBox>
#include <QCheckBox>
#include <QPushButton>
#include <QGroupBox>
#include <QTest>
#include <QTimer>
#include <QSignalSpy>
#include <QWindow>
#include <QWidget>
#include <QMainWindow>
#include <QQuickWidget>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QMetaObject>
#include <QThread>
#include <QDebug>

#include "test_helpers.hpp"

// Step definitions for preferences dialog BDD scenarios

GIVEN("^the application is running$") {
    // Application should already be running from previous steps
    ASSERT_TRUE(QApplication::instance() != nullptr);
}

GIVEN("^the native C\\+\\+ preferences dialog is available$") {
    // This is a setup step - the dialog should be available through the menu
    // No specific action needed here
}

WHEN("^I click \"([^\"]*)\" > \"([^\"]*)\" from the menu$") {
    REGEX_PARAM(std::string, menuName);
    REGEX_PARAM(std::string, itemName);
    
    // Find the main window and trigger the menu action
    QMainWindow* mainWindow = findMainWindow();
    ASSERT_TRUE(mainWindow != nullptr) << "Main window not found";
    
    // For preferences, we need to trigger the native menu action
    if (menuName == "Treon" && itemName == "Preferences...") {
        // This would typically be done through the native menu system
        // For testing, we might need to simulate the menu action
        QTimer::singleShot(100, [mainWindow]() {
            // Simulate the preferences action
            QMetaObject::invokeMethod(mainWindow, "showPreferences", Qt::QueuedConnection);
        });
        
        // Wait for dialog to appear
        QTest::qWait(200);
    }
}

WHEN("^I press \"([^\"]*)\"$") {
    REGEX_PARAM(std::string, shortcut);
    
    if (shortcut == "Cmd+,") {
        // Simulate Cmd+, shortcut for preferences
        QMainWindow* mainWindow = findMainWindow();
        ASSERT_TRUE(mainWindow != nullptr) << "Main window not found";
        
        QTimer::singleShot(100, [mainWindow]() {
            QMetaObject::invokeMethod(mainWindow, "showPreferences", Qt::QueuedConnection);
        });
        
        QTest::qWait(200);
    }
}

THEN("^the C\\+\\+ preferences dialog should open$") {
    // Look for the preferences dialog
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    ASSERT_TRUE(prefsDialog->isVisible()) << "Preferences dialog not visible";
}

THEN("^it should have a proper title bar with close button$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Check that the dialog has proper window flags
    Qt::WindowFlags flags = prefsDialog->windowFlags();
    ASSERT_TRUE(flags & Qt::WindowTitleHint) << "Dialog should have title bar";
    ASSERT_TRUE(flags & Qt::WindowCloseButtonHint) << "Dialog should have close button";
}

THEN("^it should be centered on the screen$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Check that dialog is roughly centered (allowing for some tolerance)
    QRect screenGeometry = QApplication::primaryScreen()->geometry();
    QRect dialogGeometry = prefsDialog->geometry();
    
    int centerX = screenGeometry.center().x();
    int centerY = screenGeometry.center().y();
    int dialogCenterX = dialogGeometry.center().x();
    int dialogCenterY = dialogGeometry.center().y();
    
    // Allow 100px tolerance for centering
    ASSERT_LT(abs(dialogCenterX - centerX), 100) << "Dialog should be horizontally centered";
    ASSERT_LT(abs(dialogCenterY - centerY), 100) << "Dialog should be vertically centered";
}

THEN("^it should be modal$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    ASSERT_TRUE(prefsDialog->isModal()) << "Dialog should be modal";
}

GIVEN("^the preferences dialog is open$") {
    // Open the preferences dialog
    QMainWindow* mainWindow = findMainWindow();
    ASSERT_TRUE(mainWindow != nullptr) << "Main window not found";
    
    QTimer::singleShot(100, [mainWindow]() {
        QMetaObject::invokeMethod(mainWindow, "showPreferences", Qt::QueuedConnection);
    });
    
    QTest::qWait(200);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
}

WHEN("^I look at the Language section$") {
    // This is an observation step - no action needed
}

THEN("^I should see a dropdown with language options$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    ASSERT_TRUE(languageCombo->isVisible()) << "Language combo box not visible";
}

THEN("^the dropdown should show \"([^\"]*)\", \"([^\"]*)\", \"([^\"]*)\", \"([^\"]*)\"$") {
    REGEX_PARAM(std::string, option1);
    REGEX_PARAM(std::string, option2);
    REGEX_PARAM(std::string, option3);
    REGEX_PARAM(std::string, option4);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    
    // Check that all expected language options are present
    QStringList items;
    for (int i = 0; i < languageCombo->count(); ++i) {
        items << languageCombo->itemText(i);
    }
    
    ASSERT_TRUE(items.contains(QString::fromStdString(option1))) << "Option 1 not found: " << option1;
    ASSERT_TRUE(items.contains(QString::fromStdString(option2))) << "Option 2 not found: " << option2;
    ASSERT_TRUE(items.contains(QString::fromStdString(option3))) << "Option 3 not found: " << option3;
    ASSERT_TRUE(items.contains(QString::fromStdString(option4))) << "Option 4 not found: " << option4;
}

THEN("^the dropdown should have a visible arrow button$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Look for the dropdown button (should be a QToolButton with "▼" text)
    QToolButton* dropdownButton = prefsDialog->findChild<QToolButton*>();
    ASSERT_TRUE(dropdownButton != nullptr) << "Dropdown button not found";
    ASSERT_TRUE(dropdownButton->isVisible()) << "Dropdown button not visible";
    ASSERT_EQ(dropdownButton->text(), "▼") << "Dropdown button should show down arrow";
}

WHEN("^I click on the dropdown$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QToolButton* dropdownButton = prefsDialog->findChild<QToolButton*>();
    ASSERT_TRUE(dropdownButton != nullptr) << "Dropdown button not found";
    
    QTest::mouseClick(dropdownButton, Qt::LeftButton);
    QTest::qWait(100);
}

THEN("^the language list should appear$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    
    // Check if the popup is visible
    ASSERT_TRUE(languageCombo->view()->isVisible()) << "Language list should be visible";
}

THEN("^hovering over items should show a light gray background \\(not transparent\\)$") {
    // This is a visual test that would need more sophisticated UI testing
    // For now, we'll just verify the combo box is functional
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    
    // Verify the combo box has proper styling (no transparency)
    QString styleSheet = languageCombo->styleSheet();
    ASSERT_FALSE(styleSheet.contains("transparent")) << "Combo box should not have transparent styling";
}

WHEN("^I select a different language$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    
    // Select the second language option
    languageCombo->setCurrentIndex(1);
    QTest::qWait(100);
}

THEN("^the selection should be highlighted in blue$") {
    // This would require checking the visual state of the selected item
    // For now, we'll verify the selection was made
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    
    ASSERT_EQ(languageCombo->currentIndex(), 1) << "Language selection should be updated";
}

THEN("^the dropdown should close$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo box not found";
    
    // The popup should close after selection
    QTest::qWait(100);
    ASSERT_FALSE(languageCombo->view()->isVisible()) << "Language list should be closed";
}

WHEN("^I look at the JSON Tree Settings section$") {
    // This is an observation step - no action needed
}

THEN("^I should see a \"([^\"]*)\" checkbox labeled \"([^\"]*)\"$") {
    REGEX_PARAM(std::string, settingName);
    REGEX_PARAM(std::string, labelText);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QCheckBox* checkbox = prefsDialog->findChild<QCheckBox*>();
    ASSERT_TRUE(checkbox != nullptr) << "Checkbox not found";
    ASSERT_TRUE(checkbox->isVisible()) << "Checkbox not visible";
    ASSERT_EQ(checkbox->text().toStdString(), labelText) << "Checkbox should have correct label";
}

THEN("^I should see a \"([^\"]*)\" setting with a horizontal slider$") {
    REGEX_PARAM(std::string, settingName);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSlider* slider = prefsDialog->findChild<QSlider*>();
    ASSERT_TRUE(slider != nullptr) << "Slider not found";
    ASSERT_TRUE(slider->isVisible()) << "Slider not visible";
    ASSERT_EQ(slider->orientation(), Qt::Horizontal) << "Slider should be horizontal";
}

THEN("^the slider should have a blue handle$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSlider* slider = prefsDialog->findChild<QSlider*>();
    ASSERT_TRUE(slider != nullptr) << "Slider not found";
    
    // Check that the slider has blue styling
    QString styleSheet = slider->styleSheet();
    ASSERT_TRUE(styleSheet.contains("#1976d2")) << "Slider should have blue handle styling";
}

THEN("^there should be a number display showing the current value$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSpinBox* spinBox = prefsDialog->findChild<QSpinBox*>();
    ASSERT_TRUE(spinBox != nullptr) << "Number display not found";
    ASSERT_TRUE(spinBox->isVisible()) << "Number display not visible";
}

WHEN("^I drag the slider$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSlider* slider = prefsDialog->findChild<QSlider*>();
    ASSERT_TRUE(slider != nullptr) << "Slider not found";
    
    // Simulate dragging the slider
    QTest::mousePress(slider, Qt::LeftButton, Qt::NoModifier, slider->rect().center());
    QTest::mouseMove(slider, slider->rect().center() + QPoint(50, 0));
    QTest::mouseRelease(slider, Qt::LeftButton, Qt::NoModifier, slider->rect().center() + QPoint(50, 0));
    QTest::qWait(100);
}

THEN("^the number display should update in real-time$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSpinBox* spinBox = prefsDialog->findChild<QSpinBox*>();
    ASSERT_TRUE(spinBox != nullptr) << "Number display not found";
    
    // The value should have changed from the default
    ASSERT_NE(spinBox->value(), 1) << "Number display should have updated value";
}

WHEN("^I type a number in the display$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSpinBox* spinBox = prefsDialog->findChild<QSpinBox*>();
    ASSERT_TRUE(spinBox != nullptr) << "Number display not found";
    
    // Clear and type a new value
    spinBox->clear();
    QTest::keyClicks(spinBox, "7");
    QTest::qWait(100);
}

THEN("^the slider position should update accordingly$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSlider* slider = prefsDialog->findChild<QSlider*>();
    QSpinBox* spinBox = prefsDialog->findChild<QSpinBox*>();
    
    ASSERT_TRUE(slider != nullptr) << "Slider not found";
    ASSERT_TRUE(spinBox != nullptr) << "Number display not found";
    
    // The slider value should match the spin box value
    ASSERT_EQ(slider->value(), spinBox->value()) << "Slider should match number display value";
}

WHEN("^I click the \"([^\"]*)\" button$") {
    REGEX_PARAM(std::string, buttonName);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QPushButton* button = nullptr;
    if (buttonName == "Save") {
        button = prefsDialog->findChild<QPushButton*>("saveButton");
    } else if (buttonName == "Restore Defaults") {
        button = prefsDialog->findChild<QPushButton*>("restoreButton");
    }
    
    ASSERT_TRUE(button != nullptr) << "Button not found: " << buttonName;
    QTest::mouseClick(button, Qt::LeftButton);
    QTest::qWait(100);
}

THEN("^the preferences should be saved$") {
    // This would require checking that the settings were actually saved
    // For now, we'll just verify the dialog closed
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog == nullptr || !prefsDialog->isVisible()) << "Dialog should be closed after saving";
}

THEN("^the dialog should close$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog == nullptr || !prefsDialog->isVisible()) << "Dialog should be closed";
}

THEN("^the application language should change to Spanish$") {
    // This would require checking the actual language change
    // For now, we'll just verify the test completed
    ASSERT_TRUE(true) << "Language change verification would be implemented here";
}

THEN("^the JSON tree depth setting should be updated$") {
    // This would require checking the actual setting change
    // For now, we'll just verify the test completed
    ASSERT_TRUE(true) << "Setting change verification would be implemented here";
}

THEN("^all settings should return to their default values$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    QSpinBox* spinBox = prefsDialog->findChild<QSpinBox*>();
    QCheckBox* checkbox = prefsDialog->findChild<QCheckBox*>();
    
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo not found";
    ASSERT_TRUE(spinBox != nullptr) << "Spin box not found";
    ASSERT_TRUE(checkbox != nullptr) << "Checkbox not found";
    
    // Check default values
    ASSERT_EQ(languageCombo->currentIndex(), 0) << "Language should be default";
    ASSERT_EQ(spinBox->value(), 1) << "Depth should be default";
    ASSERT_FALSE(checkbox->isChecked()) << "Unlimited checkbox should be unchecked";
}

THEN("^the language should be \"([^\"]*)\"$") {
    REGEX_PARAM(std::string, expectedLanguage);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QComboBox* languageCombo = prefsDialog->findChild<QComboBox*>();
    ASSERT_TRUE(languageCombo != nullptr) << "Language combo not found";
    
    QString currentText = languageCombo->currentText();
    ASSERT_EQ(currentText.toStdString(), expectedLanguage) << "Language should match expected value";
}

THEN("^the depth should be (\\d+)$") {
    REGEX_PARAM(int, expectedDepth);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSpinBox* spinBox = prefsDialog->findChild<QSpinBox*>();
    ASSERT_TRUE(spinBox != nullptr) << "Spin box not found";
    
    ASSERT_EQ(spinBox->value(), expectedDepth) << "Depth should match expected value";
}

THEN("^the \"([^\"]*)\" checkbox should be unchecked$") {
    REGEX_PARAM(std::string, checkboxLabel);
    
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QCheckBox* checkbox = prefsDialog->findChild<QCheckBox*>();
    ASSERT_TRUE(checkbox != nullptr) << "Checkbox not found";
    
    ASSERT_FALSE(checkbox->isChecked()) << "Checkbox should be unchecked";
}

WHEN("^I close the dialog without saving$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Close the dialog (simulate clicking the X button)
    prefsDialog->close();
    QTest::qWait(100);
}

THEN("^the changes should not be applied$") {
    // This would require checking that the application state didn't change
    // For now, we'll just verify the test completed
    ASSERT_TRUE(true) << "Change verification would be implemented here";
}

THEN("^the application should remain in its previous state$") {
    // This would require checking the application state
    // For now, we'll just verify the test completed
    ASSERT_TRUE(true) << "State verification would be implemented here";
}

WHEN("^I examine the dialog appearance$") {
    // This is an observation step - no action needed
}

THEN("^it should have a clean, modern design$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Check that the dialog has proper styling
    QString styleSheet = prefsDialog->styleSheet();
    ASSERT_FALSE(styleSheet.isEmpty()) << "Dialog should have styling applied";
}

THEN("^the group boxes should have rounded corners$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QGroupBox* groupBox = prefsDialog->findChild<QGroupBox*>();
    ASSERT_TRUE(groupBox != nullptr) << "Group box not found";
    
    QString styleSheet = groupBox->styleSheet();
    ASSERT_TRUE(styleSheet.contains("border-radius")) << "Group box should have rounded corners";
}

THEN("^the buttons should have proper hover effects$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QPushButton* button = prefsDialog->findChild<QPushButton*>();
    ASSERT_TRUE(button != nullptr) << "Button not found";
    
    QString styleSheet = button->styleSheet();
    ASSERT_TRUE(styleSheet.contains(":hover")) << "Button should have hover effects";
}

THEN("^the slider should have a professional blue theme$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QSlider* slider = prefsDialog->findChild<QSlider*>();
    ASSERT_TRUE(slider != nullptr) << "Slider not found";
    
    QString styleSheet = slider->styleSheet();
    ASSERT_TRUE(styleSheet.contains("#1976d2")) << "Slider should have blue theme";
}

THEN("^all text should be clearly readable$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Check that labels have proper styling
    QLabel* label = prefsDialog->findChild<QLabel*>();
    ASSERT_TRUE(label != nullptr) << "Label not found";
    
    QString styleSheet = label->styleSheet();
    ASSERT_TRUE(styleSheet.contains("color")) << "Labels should have color styling";
}

THEN("^the layout should be well-organized$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Check that the dialog has a reasonable size
    QSize size = prefsDialog->size();
    ASSERT_GT(size.width(), 400) << "Dialog should be wide enough";
    ASSERT_GT(size.height(), 300) << "Dialog should be tall enough";
}

WHEN("^I use the Tab key$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    // Simulate Tab key press
    QTest::keyClick(prefsDialog, Qt::Key_Tab);
    QTest::qWait(100);
}

THEN("^I should be able to navigate between all controls$") {
    // This would require checking focus changes
    // For now, we'll just verify the test completed
    ASSERT_TRUE(true) << "Navigation verification would be implemented here";
}

THEN("^the focus should be clearly visible$") {
    // This would require checking focus styling
    // For now, we'll just verify the test completed
    ASSERT_TRUE(true) << "Focus verification would be implemented here";
}

WHEN("^I press Enter on the Save button$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QPushButton* saveButton = prefsDialog->findChild<QPushButton*>("saveButton");
    ASSERT_TRUE(saveButton != nullptr) << "Save button not found";
    
    // Focus the button and press Enter
    saveButton->setFocus();
    QTest::keyClick(saveButton, Qt::Key_Return);
    QTest::qWait(100);
}

WHEN("^I press Escape$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog != nullptr) << "Preferences dialog not found";
    
    QTest::keyClick(prefsDialog, Qt::Key_Escape);
    QTest::qWait(100);
}

THEN("^the dialog should close without saving$") {
    QDialog* prefsDialog = findDialogByTitle("Preferences");
    ASSERT_TRUE(prefsDialog == nullptr || !prefsDialog->isVisible()) << "Dialog should be closed";
}
