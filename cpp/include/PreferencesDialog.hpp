#pragma once

#include <QDialog>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QComboBox>
#include <QCheckBox>
#include <QSpinBox>
#include <QPushButton>
#include <QGroupBox>
#include <QSettings>
#include <QTranslator>

namespace treon {

class PreferencesDialog : public QDialog
{
    Q_OBJECT

public:
    explicit PreferencesDialog(QWidget *parent = nullptr);
    ~PreferencesDialog();

private slots:
    void onLanguageChanged(const QString &language);
    void onMaxDepthToggled(bool unlimited);
    void onDepthChanged(int depth);
    void onRestoreDefaults();
    void onSave();

signals:
    void languageChanged(const QString &language);

private:
    void setupUI();
    void loadSettings();
    void saveSettings();
    void applyLanguage(const QString &language);
    void populateLanguageOptions();

    // UI Components
    QVBoxLayout *m_mainLayout;
    QGroupBox *m_languageGroup;
    QGroupBox *m_jsonTreeGroup;
    QComboBox *m_languageCombo;
    QCheckBox *m_unlimitedDepthCheck;
    QSpinBox *m_depthSpin;
    QPushButton *m_restoreButton;
    QPushButton *m_saveButton;

    // Settings
    QSettings *m_settings;
    QString m_originalLanguage;
    bool m_originalUnlimitedDepth;
    int m_originalDepth;
};

} // namespace treon
