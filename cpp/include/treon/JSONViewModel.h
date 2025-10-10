#pragma once

#include <QObject>
#include <QString>
#include <memory>

#include "treon/JSONNode.h"

namespace treon {

class JSONViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString jsonText READ jsonText NOTIFY jsonTextChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)

public:
    explicit JSONViewModel(QObject *parent = nullptr);
    ~JSONViewModel() override = default;

    QString jsonText() const { return m_jsonText; }
    bool isValid() const { return m_isValid; }

public slots:
    void setJSON(const QString &json);
    void clear();

signals:
    void jsonTextChanged();
    void isValidChanged();

private:
    void updateValidation();

    QString m_jsonText;
    bool m_isValid = false;
    std::shared_ptr<JSONNode> m_rootNode;
};

} // namespace treon
