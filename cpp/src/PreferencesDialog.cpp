#include "PreferencesDialog.hpp"
#include <QApplication>
#include <QDebug>
#include <QToolButton>

namespace treon {

PreferencesDialog::PreferencesDialog(QWidget *parent)
    : QDialog(parent)
    , m_settings(new QSettings(this))
{
    setWindowTitle(tr("Preferences"));
    setModal(true);
    setFixedSize(500, 400);
    
    // Set dialog style
    setStyleSheet(
        "QDialog {"
        "    background-color: #ffffff;"
        "    border: 1px solid #cccccc;"
        "    border-radius: 10px;"
        "}"
    );
    
    setupUI();
    loadSettings();
}

PreferencesDialog::~PreferencesDialog() = default;

void PreferencesDialog::setupUI()
{
    // Set up main layout with proper spacing
    m_mainLayout = new QVBoxLayout(this);
    m_mainLayout->setContentsMargins(20, 20, 20, 20);
    m_mainLayout->setSpacing(20);
    
    // Language Group
    m_languageGroup = new QGroupBox(tr("Language"), this);
    m_languageGroup->setStyleSheet(
        "QGroupBox {"
        "    font-weight: bold;"
        "    font-size: 14px;"
        "    color: #333333;"
        "    border: 1px solid #cccccc;"
        "    border-radius: 8px;"
        "    margin-top: 10px;"
        "    padding-top: 10px;"
        "}"
        "QGroupBox::title {"
        "    subcontrol-origin: margin;"
        "    left: 10px;"
        "    padding: 0 5px 0 5px;"
        "    background-color: white;"
        "}"
    );
    
    QVBoxLayout *languageLayout = new QVBoxLayout(m_languageGroup);
    languageLayout->setContentsMargins(15, 15, 15, 15);
    languageLayout->setSpacing(10);
    
    QLabel *languageDescription = new QLabel(tr("Choose your preferred language for the application interface."), this);
    languageDescription->setStyleSheet("color: #666666; font-size: 12px;");
    languageDescription->setWordWrap(true);
    languageLayout->addWidget(languageDescription);
    
    // Create a custom language selector with a button and popup menu
    QHBoxLayout *languageSelectorLayout = new QHBoxLayout();
    languageSelectorLayout->setSpacing(0);
    
    m_languageCombo = new QComboBox(this);
    m_languageCombo->setStyleSheet(
        "QComboBox {"
        "    border: 1px solid #cccccc;"
        "    border-radius: 4px 0px 0px 4px;"
        "    padding: 8px 12px;"
        "    font-size: 13px;"
        "    background-color: white;"
        "    min-height: 20px;"
        "}"
        "QComboBox:hover {"
        "    border-color: #999999;"
        "}"
        "QComboBox::drop-down {"
        "    border: none;"
        "    width: 0px;"
        "}"
        "QComboBox QAbstractItemView {"
        "    border: 1px solid #cccccc;"
        "    border-radius: 4px;"
        "    background-color: white;"
        "    selection-background-color: #e3f2fd;"
        "    selection-color: #1976d2;"
        "}"
        "QComboBox QAbstractItemView::item {"
        "    padding: 8px 12px;"
        "    border: none;"
        "    background-color: white;"
        "    color: #333333;"
        "}"
        "QComboBox QAbstractItemView::item:hover {"
        "    background-color: #f5f5f5;"
        "    color: #333333;"
        "}"
        "QComboBox QAbstractItemView::item:selected {"
        "    background-color: #e3f2fd;"
        "    color: #1976d2;"
        "}"
    );
    m_languageCombo->addItem("🇬🇧 English (UK)", "en_GB");
    m_languageCombo->addItem("🇺🇸 English (US)", "en_US");
    m_languageCombo->addItem("🇪🇸 Español", "es");
    m_languageCombo->addItem("🇫🇷 Français", "fr");
    
    // Create a dropdown button with arrow
    QToolButton *dropdownButton = new QToolButton(this);
    dropdownButton->setText("▼");
    dropdownButton->setStyleSheet(
        "QToolButton {"
        "    border: 1px solid #cccccc;"
        "    border-left: none;"
        "    border-radius: 0px 4px 4px 0px;"
        "    padding: 8px 12px;"
        "    font-size: 12px;"
        "    background-color: #f5f5f5;"
        "    color: #666666;"
        "    min-width: 20px;"
        "    font-weight: bold;"
        "}"
        "QToolButton:hover {"
        "    background-color: #e5e5e5;"
        "    border-color: #999999;"
        "}"
    );
    
    // Connect dropdown button to combo box
    connect(dropdownButton, &QToolButton::clicked, [this]() {
        m_languageCombo->showPopup();
    });
    
    languageSelectorLayout->addWidget(m_languageCombo);
    languageSelectorLayout->addWidget(dropdownButton);
    
    languageLayout->addLayout(languageSelectorLayout);
    m_mainLayout->addWidget(m_languageGroup);
    
    // JSON Tree Settings Group
    m_jsonTreeGroup = new QGroupBox(tr("JSON Tree Settings"), this);
    m_jsonTreeGroup->setStyleSheet(
        "QGroupBox {"
        "    font-weight: bold;"
        "    font-size: 14px;"
        "    color: #333333;"
        "    border: 1px solid #cccccc;"
        "    border-radius: 8px;"
        "    margin-top: 10px;"
        "    padding-top: 10px;"
        "}"
        "QGroupBox::title {"
        "    subcontrol-origin: margin;"
        "    left: 10px;"
        "    padding: 0 5px 0 5px;"
        "    background-color: white;"
        "}"
    );
    
    QVBoxLayout *jsonLayout = new QVBoxLayout(m_jsonTreeGroup);
    jsonLayout->setContentsMargins(15, 15, 15, 15);
    jsonLayout->setSpacing(15);
    
    QLabel *jsonDescription = new QLabel(tr("Configure how JSON data is displayed in the tree view."), this);
    jsonDescription->setStyleSheet("color: #666666; font-size: 12px;");
    jsonDescription->setWordWrap(true);
    jsonLayout->addWidget(jsonDescription);
    
    // Max Depth
    QHBoxLayout *maxDepthLayout = new QHBoxLayout();
    maxDepthLayout->setSpacing(10);
    
    QLabel *maxDepthLabel = new QLabel(tr("Max Depth:"), this);
    maxDepthLabel->setStyleSheet("font-weight: 500; color: #333333; min-width: 80px;");
    maxDepthLabel->setAlignment(Qt::AlignRight | Qt::AlignVCenter);
    
    m_unlimitedDepthCheck = new QCheckBox(tr("Unlimited"), this);
    m_unlimitedDepthCheck->setStyleSheet(
        "QCheckBox {"
        "    font-size: 13px;"
        "    color: #333333;"
        "    spacing: 8px;"
        "}"
        "QCheckBox::indicator {"
        "    width: 16px;"
        "    height: 16px;"
        "    border: 1px solid #cccccc;"
        "    border-radius: 3px;"
        "    background-color: white;"
        "}"
        "QCheckBox::indicator:checked {"
        "    background-color: #007AFF;"
        "    border-color: #007AFF;"
        "    image: none;"
        "}"
        "QCheckBox::indicator:checked:after {"
        "    content: '✓';"
        "    color: white;"
        "    font-weight: bold;"
        "}"
    );
    
    maxDepthLayout->addWidget(maxDepthLabel);
    maxDepthLayout->addWidget(m_unlimitedDepthCheck);
    maxDepthLayout->addStretch();
    jsonLayout->addLayout(maxDepthLayout);
    
    // Depth
    QHBoxLayout *depthLayout = new QHBoxLayout();
    depthLayout->setSpacing(10);
    
    QLabel *depthLabel = new QLabel(tr("Depth:"), this);
    depthLabel->setStyleSheet("font-weight: 500; color: #333333; min-width: 80px;");
    depthLabel->setAlignment(Qt::AlignRight | Qt::AlignVCenter);
    
    // Create a slider layout
    QHBoxLayout *sliderLayout = new QHBoxLayout();
    sliderLayout->setSpacing(10);
    
    m_depthSpin = new QSpinBox(this);
    m_depthSpin->setRange(1, 10);
    m_depthSpin->setValue(1);
    m_depthSpin->setButtonSymbols(QSpinBox::NoButtons);
    m_depthSpin->setStyleSheet(
        "QSpinBox {"
        "    border: 1px solid #cccccc;"
        "    border-radius: 4px;"
        "    padding: 6px 8px;"
        "    font-size: 13px;"
        "    background-color: white;"
        "    min-width: 50px;"
        "    max-width: 50px;"
        "}"
        "QSpinBox:hover {"
        "    border-color: #999999;"
        "}"
    );
    
    // Create slider
    QSlider *depthSlider = new QSlider(Qt::Horizontal, this);
    depthSlider->setRange(1, 10);
    depthSlider->setValue(1);
    depthSlider->setStyleSheet(
        "QSlider::groove:horizontal {"
        "    border: 1px solid #cccccc;"
        "    height: 6px;"
        "    background: #f0f0f0;"
        "    border-radius: 3px;"
        "}"
        "QSlider::handle:horizontal {"
        "    background: #1976d2;"
        "    border: 1px solid #1976d2;"
        "    width: 18px;"
        "    margin: -6px 0;"
        "    border-radius: 9px;"
        "}"
        "QSlider::handle:horizontal:hover {"
        "    background: #1565c0;"
        "    border: 1px solid #1565c0;"
        "}"
        "QSlider::sub-page:horizontal {"
        "    background: #1976d2;"
        "    border: 1px solid #1976d2;"
        "    height: 6px;"
        "    border-radius: 3px;"
        "}"
    );
    
    // Connect slider and spin box
    connect(depthSlider, &QSlider::valueChanged, m_depthSpin, &QSpinBox::setValue);
    connect(m_depthSpin, QOverload<int>::of(&QSpinBox::valueChanged), depthSlider, &QSlider::setValue);
    
    sliderLayout->addWidget(depthSlider);
    sliderLayout->addWidget(m_depthSpin);
    
    depthLayout->addWidget(depthLabel);
    depthLayout->addLayout(sliderLayout);
    depthLayout->addStretch();
    jsonLayout->addLayout(depthLayout);
    
    m_mainLayout->addWidget(m_jsonTreeGroup);
    m_mainLayout->addStretch();
    
    // Buttons
    QHBoxLayout *buttonLayout = new QHBoxLayout();
    buttonLayout->setSpacing(10);
    
    m_restoreButton = new QPushButton(tr("Restore Defaults"), this);
    m_restoreButton->setStyleSheet(
        "QPushButton {"
        "    background-color: #f5f5f5;"
        "    border: 1px solid #cccccc;"
        "    border-radius: 6px;"
        "    padding: 8px 16px;"
        "    font-size: 13px;"
        "    color: #333333;"
        "    min-width: 100px;"
        "}"
        "QPushButton:hover {"
        "    background-color: #e5e5e5;"
        "    border-color: #999999;"
        "}"
        "QPushButton:pressed {"
        "    background-color: #d5d5d5;"
        "}"
    );
    
    m_saveButton = new QPushButton(tr("Save"), this);
    m_saveButton->setDefault(true);
    m_saveButton->setStyleSheet(
        "QPushButton {"
        "    background-color: #007AFF;"
        "    border: 1px solid #007AFF;"
        "    border-radius: 6px;"
        "    padding: 8px 20px;"
        "    font-size: 13px;"
        "    color: white;"
        "    font-weight: 500;"
        "    min-width: 80px;"
        "}"
        "QPushButton:hover {"
        "    background-color: #0056CC;"
        "    border-color: #0056CC;"
        "}"
        "QPushButton:pressed {"
        "    background-color: #004499;"
        "}"
    );
    
    buttonLayout->addStretch();
    buttonLayout->addWidget(m_restoreButton);
    buttonLayout->addWidget(m_saveButton);
    
    m_mainLayout->addLayout(buttonLayout);
    
    // Connections
    connect(m_languageCombo, QOverload<const QString &>::of(&QComboBox::currentTextChanged),
            this, &PreferencesDialog::onLanguageChanged);
    connect(m_unlimitedDepthCheck, &QCheckBox::toggled,
            this, &PreferencesDialog::onMaxDepthToggled);
    connect(m_depthSpin, QOverload<int>::of(&QSpinBox::valueChanged),
            this, &PreferencesDialog::onDepthChanged);
    connect(m_restoreButton, &QPushButton::clicked,
            this, &PreferencesDialog::onRestoreDefaults);
    connect(m_saveButton, &QPushButton::clicked,
            this, &PreferencesDialog::onSave);
}

void PreferencesDialog::loadSettings()
{
    // Load language
    QString language = m_settings->value("language", "en_GB").toString();
    int index = m_languageCombo->findData(language);
    if (index >= 0) {
        m_languageCombo->setCurrentIndex(index);
    }
    m_originalLanguage = language;
    
    // Load JSON tree settings
    bool unlimited = m_settings->value("jsonTree/unlimitedDepth", false).toBool();
    m_unlimitedDepthCheck->setChecked(unlimited);
    m_originalUnlimitedDepth = unlimited;
    
    int depth = m_settings->value("jsonTree/depth", 1).toInt();
    m_depthSpin->setValue(depth);
    m_originalDepth = depth;
    
    // Enable/disable depth spin based on unlimited checkbox
    m_depthSpin->setEnabled(!unlimited);
}

void PreferencesDialog::saveSettings()
{
    // Save language
    QString language = m_languageCombo->currentData().toString();
    m_settings->setValue("language", language);
    
    // Save JSON tree settings
    m_settings->setValue("jsonTree/unlimitedDepth", m_unlimitedDepthCheck->isChecked());
    m_settings->setValue("jsonTree/depth", m_depthSpin->value());
    
    m_settings->sync();
}

void PreferencesDialog::applyLanguage(const QString &language)
{
    // This would integrate with the I18nManager
    // For now, just emit a signal that the main application can handle
    emit languageChanged(language);
}

void PreferencesDialog::onLanguageChanged(const QString &language)
{
    Q_UNUSED(language)
    // Language change will be applied on save
}

void PreferencesDialog::onMaxDepthToggled(bool unlimited)
{
    m_depthSpin->setEnabled(!unlimited);
}

void PreferencesDialog::onDepthChanged(int depth)
{
    Q_UNUSED(depth)
    // Depth change will be applied on save
}

void PreferencesDialog::onRestoreDefaults()
{
    m_languageCombo->setCurrentIndex(0); // English (UK)
    m_unlimitedDepthCheck->setChecked(false);
    m_depthSpin->setValue(1);
    m_depthSpin->setEnabled(true);
}

void PreferencesDialog::onSave()
{
    saveSettings();
    
    // Apply language change if different
    QString newLanguage = m_languageCombo->currentData().toString();
    if (newLanguage != m_originalLanguage) {
        applyLanguage(newLanguage);
    }
    
    accept();
}


} // namespace treon

#include "PreferencesDialog.moc"
