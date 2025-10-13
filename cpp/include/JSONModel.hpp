#ifndef JSON_MODEL_HPP
#define JSON_MODEL_HPP

#include <QAbstractItemModel>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QModelIndex>
#include <QVariant>
#include <QString>
#include <QStringList>
#include <QIcon>

namespace treon {

class JSONItem;

class JSONModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit JSONModel(QObject *parent = nullptr);
    ~JSONModel();

    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // JSON-specific methods
    void loadJSON(const QJsonDocument &document);
    void loadJSON(const QString &jsonString);
    void clear();
    bool isEmpty() const;
    QString getRawJSON() const;
    QJsonDocument getDocument() const;
    
    // Tree navigation
    JSONItem* getItem(const QModelIndex &index) const;
    QModelIndex findKey(const QString &key, const QModelIndex &startFrom = QModelIndex()) const;
    
    // Flat list for ListView
    QVariantList getFlatList() const;
    // maxDepth < 0 => unlimited
    QVariantList getFlatListWithExpansion(int maxDepth = -1) const;
    
    // Tree expansion management
    void setItemExpanded(int index, bool expanded);
    bool isItemExpanded(int index) const;
    void expandAll();
    void collapseAll();
    
    // JSON operations
    bool isValidJSON() const;
    QString getErrorMessage() const;
    int getTotalItems() const;
    int getMaxDepth() const;
    int getMaxDepth(const QJsonDocument &doc) const;

signals:
    void jsonLoaded();
    void jsonCleared();
    void errorOccurred(const QString &message);

private:
    void setupModelData(const QJsonValue &value, JSONItem *parent);
    JSONItem* createItem(const QJsonValue &value, JSONItem *parent);
    QString formatValue(const QJsonValue &value) const;
    QIcon getIconForType(QJsonValue::Type type) const;
    
    JSONItem *m_rootItem;
    QJsonDocument m_document;
    QString m_errorMessage;
    bool m_isValid;
    QSet<int> m_expandedItems; // Track which items are expanded
};

class JSONItem
{
public:
    explicit JSONItem(const QJsonValue &value, JSONItem *parent = nullptr);
    ~JSONItem();

    // Data access
    QVariant data(int column, int role = Qt::DisplayRole) const;
    void setData(const QVariant &value, int role = Qt::DisplayRole);
    
    // Tree structure
    JSONItem* child(int number);
    int childCount() const;
    int columnCount() const;
    JSONItem* parent();
    int childNumber() const;
    
    // JSON-specific
    QString getKey() const;
    void setKey(const QString &key);
    QJsonValue getValue() const;
    void setValue(const QJsonValue &value);
    QJsonValue::Type getType() const;
    QString getTypeString() const;
    QString getFormattedValue() const;
    bool isExpanded() const;
    void setExpanded(bool expanded);
    
    // Utility
    void appendChild(JSONItem *child);
    void removeChild(int index);
    void clearChildren();
    int getDepth() const;
    QString getPath() const;

private:
    QList<JSONItem*> m_childItems;
    JSONItem *m_parentItem;
    QString m_key;
    QJsonValue m_value;
    bool m_expanded;
    QIcon m_icon;
    
    void setupChildren();
    QString formatValue(const QJsonValue &value) const;
    QIcon getIconForType(QJsonValue::Type type) const;
};

} // namespace treon

#endif // JSON_MODEL_HPP
