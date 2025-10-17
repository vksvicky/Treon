#include <gtest/gtest.h>
#include <QApplication>
#include <QDialog>
#include <QComboBox>
#include <QSlider>
#include <QSpinBox>
#include <QCheckBox>
#include <QPushButton>
#include <QGroupBox>
#include <QSettings>
#include <QSignalSpy>
#include <QTest>
#include <QTimer>

#include "PreferencesDialog.hpp"

class PreferencesDialogTest : public ::testing::Test {
protected:
    void SetUp() override {
        if (QApplication::instance() == nullptr) {
            int argc = 0;
            char **argv = nullptr;
            app = new QApplication(argc, argv);
        } else {
            app = QApplication::instance();
        }
        
        dialog = new treon::PreferencesDialog();
    }
    
    void TearDown() override {
        if (dialog) {
            dialog->close();
            delete dialog;
            dialog = nullptr;
        }
    }
    
    QApplication *app = nullptr;
    treon::PreferencesDialog *dialog = nullptr;
};

TEST_F(PreferencesDialogTest, DialogCreation) {
    ASSERT_NE(dialog, nullptr);
    EXPECT_TRUE(dialog->isVisible());
    EXPECT_EQ(dialog->windowTitle(), "Preferences");
    EXPECT_TRUE(dialog->isModal());
}

TEST_F(PreferencesDialogTest, DialogSize) {
    QSize size = dialog->size();
    EXPECT_GT(size.width(), 400);
    EXPECT_GT(size.height(), 300);
}

TEST_F(PreferencesDialogTest, LanguageComboBox) {
    QComboBox *languageCombo = dialog->findChild<QComboBox*>();
    ASSERT_NE(languageCombo, nullptr);
    EXPECT_TRUE(languageCombo->isVisible());
    
    // Check that all expected languages are present
    QStringList items;
    for (int i = 0; i < languageCombo->count(); ++i) {
        items << languageCombo->itemText(i);
    }
    
    EXPECT_TRUE(items.contains("🇬🇧 English (UK)"));
    EXPECT_TRUE(items.contains("🇺🇸 English (US)"));
    EXPECT_TRUE(items.contains("🇪🇸 Español"));
    EXPECT_TRUE(items.contains("🇫🇷 Français"));
}

TEST_F(PreferencesDialogTest, LanguageComboBoxData) {
    QComboBox *languageCombo = dialog->findChild<QComboBox*>();
    ASSERT_NE(languageCombo, nullptr);
    
    // Check that data values are correct
    for (int i = 0; i < languageCombo->count(); ++i) {
        QString data = languageCombo->itemData(i).toString();
        EXPECT_FALSE(data.isEmpty());
        
        if (languageCombo->itemText(i).contains("English (UK)")) {
            EXPECT_EQ(data, "en_GB");
        } else if (languageCombo->itemText(i).contains("English (US)")) {
            EXPECT_EQ(data, "en_US");
        } else if (languageCombo->itemText(i).contains("Español")) {
            EXPECT_EQ(data, "es");
        } else if (languageCombo->itemText(i).contains("Français")) {
            EXPECT_EQ(data, "fr");
        }
    }
}

TEST_F(PreferencesDialogTest, DropdownButton) {
    // Look for the dropdown button (QToolButton with "▼" text)
    QToolButton *dropdownButton = dialog->findChild<QToolButton*>();
    ASSERT_NE(dropdownButton, nullptr);
    EXPECT_TRUE(dropdownButton->isVisible());
    EXPECT_EQ(dropdownButton->text(), "▼");
}

TEST_F(PreferencesDialogTest, DropdownButtonFunctionality) {
    QComboBox *languageCombo = dialog->findChild<QComboBox*>();
    QToolButton *dropdownButton = dialog->findChild<QToolButton*>();
    
    ASSERT_NE(languageCombo, nullptr);
    ASSERT_NE(dropdownButton, nullptr);
    
    // Click the dropdown button
    QTest::mouseClick(dropdownButton, Qt::LeftButton);
    QTest::qWait(100);
    
    // The combo box popup should be visible
    EXPECT_TRUE(languageCombo->view()->isVisible());
}

TEST_F(PreferencesDialogTest, UnlimitedCheckbox) {
    QCheckBox *unlimitedCheck = dialog->findChild<QCheckBox*>();
    ASSERT_NE(unlimitedCheck, nullptr);
    EXPECT_TRUE(unlimitedCheck->isVisible());
    EXPECT_EQ(unlimitedCheck->text(), "Unlimited");
    EXPECT_FALSE(unlimitedCheck->isChecked()); // Should be unchecked by default
}

TEST_F(PreferencesDialogTest, DepthSlider) {
    QSlider *depthSlider = dialog->findChild<QSlider*>();
    ASSERT_NE(depthSlider, nullptr);
    EXPECT_TRUE(depthSlider->isVisible());
    EXPECT_EQ(depthSlider->orientation(), Qt::Horizontal);
    EXPECT_EQ(depthSlider->minimum(), 1);
    EXPECT_EQ(depthSlider->maximum(), 10);
    EXPECT_EQ(depthSlider->value(), 1); // Default value
}

TEST_F(PreferencesDialogTest, DepthSpinBox) {
    QSpinBox *depthSpin = dialog->findChild<QSpinBox*>();
    ASSERT_NE(depthSpin, nullptr);
    EXPECT_TRUE(depthSpin->isVisible());
    EXPECT_EQ(depthSpin->minimum(), 1);
    EXPECT_EQ(depthSpin->maximum(), 10);
    EXPECT_EQ(depthSpin->value(), 1); // Default value
}

TEST_F(PreferencesDialogTest, SliderSpinBoxSynchronization) {
    QSlider *depthSlider = dialog->findChild<QSlider*>();
    QSpinBox *depthSpin = dialog->findChild<QSpinBox*>();
    
    ASSERT_NE(depthSlider, nullptr);
    ASSERT_NE(depthSpin, nullptr);
    
    // Change slider value
    depthSlider->setValue(5);
    QTest::qWait(100);
    
    // Spin box should update
    EXPECT_EQ(depthSpin->value(), 5);
    
    // Change spin box value
    depthSpin->setValue(8);
    QTest::qWait(100);
    
    // Slider should update
    EXPECT_EQ(depthSlider->value(), 8);
}

TEST_F(PreferencesDialogTest, SaveButton) {
    QPushButton *saveButton = dialog->findChild<QPushButton*>("saveButton");
    ASSERT_NE(saveButton, nullptr);
    EXPECT_TRUE(saveButton->isVisible());
    EXPECT_EQ(saveButton->text(), "Save");
    EXPECT_TRUE(saveButton->isDefault()); // Should be default button
}

TEST_F(PreferencesDialogTest, RestoreDefaultsButton) {
    QPushButton *restoreButton = dialog->findChild<QPushButton*>("restoreButton");
    ASSERT_NE(restoreButton, nullptr);
    EXPECT_TRUE(restoreButton->isVisible());
    EXPECT_EQ(restoreButton->text(), "Restore Defaults");
}

TEST_F(PreferencesDialogTest, LanguageChangeSignal) {
    QComboBox *languageCombo = dialog->findChild<QComboBox*>();
    ASSERT_NE(languageCombo, nullptr);
    
    // Create a spy for the languageChanged signal
    QSignalSpy spy(dialog, &treon::PreferencesDialog::languageChanged);
    
    // Change language
    languageCombo->setCurrentIndex(2); // Spanish
    QTest::qWait(100);
    
    // Signal should be emitted
    EXPECT_GT(spy.count(), 0);
    
    // Check the signal arguments
    QList<QVariant> arguments = spy.takeFirst();
    EXPECT_EQ(arguments.at(0).toString(), "es");
}

TEST_F(PreferencesDialogTest, SaveButtonClick) {
    QPushButton *saveButton = dialog->findChild<QPushButton*>("saveButton");
    ASSERT_NE(saveButton, nullptr);
    
    // Click save button
    QTest::mouseClick(saveButton, Qt::LeftButton);
    QTest::qWait(100);
    
    // Dialog should close
    EXPECT_FALSE(dialog->isVisible());
}

TEST_F(PreferencesDialogTest, RestoreDefaultsFunctionality) {
    QComboBox *languageCombo = dialog->findChild<QComboBox*>();
    QSlider *depthSlider = dialog->findChild<QSlider*>();
    QCheckBox *unlimitedCheck = dialog->findChild<QCheckBox*>();
    QPushButton *restoreButton = dialog->findChild<QPushButton*>("restoreButton");
    
    ASSERT_NE(languageCombo, nullptr);
    ASSERT_NE(depthSlider, nullptr);
    ASSERT_NE(unlimitedCheck, nullptr);
    ASSERT_NE(restoreButton, nullptr);
    
    // Change some values
    languageCombo->setCurrentIndex(2); // Spanish
    depthSlider->setValue(7);
    unlimitedCheck->setChecked(true);
    
    // Click restore defaults
    QTest::mouseClick(restoreButton, Qt::LeftButton);
    QTest::qWait(100);
    
    // Values should be restored
    EXPECT_EQ(languageCombo->currentIndex(), 0); // English (UK)
    EXPECT_EQ(depthSlider->value(), 1);
    EXPECT_FALSE(unlimitedCheck->isChecked());
}

TEST_F(PreferencesDialogTest, Styling) {
    // Check that the dialog has styling applied
    QString styleSheet = dialog->styleSheet();
    EXPECT_FALSE(styleSheet.isEmpty());
    
    // Check group boxes have styling
    QGroupBox *groupBox = dialog->findChild<QGroupBox*>();
    ASSERT_NE(groupBox, nullptr);
    QString groupStyleSheet = groupBox->styleSheet();
    EXPECT_FALSE(groupStyleSheet.isEmpty());
    EXPECT_TRUE(groupStyleSheet.contains("border-radius"));
    
    // Check slider has blue styling
    QSlider *depthSlider = dialog->findChild<QSlider*>();
    ASSERT_NE(depthSlider, nullptr);
    QString sliderStyleSheet = depthSlider->styleSheet();
    EXPECT_TRUE(sliderStyleSheet.contains("#1976d2"));
    
    // Check buttons have hover effects
    QPushButton *saveButton = dialog->findChild<QPushButton*>("saveButton");
    ASSERT_NE(saveButton, nullptr);
    QString buttonStyleSheet = saveButton->styleSheet();
    EXPECT_TRUE(buttonStyleSheet.contains(":hover"));
}

TEST_F(PreferencesDialogTest, KeyboardNavigation) {
    // Test Tab navigation
    QTest::keyClick(dialog, Qt::Key_Tab);
    QTest::qWait(100);
    
    // Test Enter on Save button
    QPushButton *saveButton = dialog->findChild<QPushButton*>("saveButton");
    ASSERT_NE(saveButton, nullptr);
    
    saveButton->setFocus();
    QTest::keyClick(saveButton, Qt::Key_Return);
    QTest::qWait(100);
    
    // Dialog should close
    EXPECT_FALSE(dialog->isVisible());
}

TEST_F(PreferencesDialogTest, EscapeKey) {
    // Test Escape key closes dialog
    QTest::keyClick(dialog, Qt::Key_Escape);
    QTest::qWait(100);
    
    // Dialog should close
    EXPECT_FALSE(dialog->isVisible());
}

TEST_F(PreferencesDialogTest, DialogModal) {
    EXPECT_TRUE(dialog->isModal());
}

TEST_F(PreferencesDialogTest, DialogCentered) {
    // Check that dialog is roughly centered
    QRect screenGeometry = QApplication::primaryScreen()->geometry();
    QRect dialogGeometry = dialog->geometry();
    
    int centerX = screenGeometry.center().x();
    int centerY = screenGeometry.center().y();
    int dialogCenterX = dialogGeometry.center().x();
    int dialogCenterY = dialogGeometry.center().y();
    
    // Allow 100px tolerance for centering
    EXPECT_LT(abs(dialogCenterX - centerX), 100);
    EXPECT_LT(abs(dialogCenterY - centerY), 100);
}
