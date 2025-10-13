#include "JSONModel.hpp"
#include <QJsonParseError>
#include <QDebug>
#include <QFont>
#include <QColor>

namespace treon {

// JSONModel Implementation
JSONModel::JSONModel(QObject *parent)
    : QAbstractItemModel(parent)
    , m_rootItem(nullptr)
    , m_isValid(false)
{
    m_rootItem = new JSONItem(QJsonValue(), nullptr);
}

JSONModel::~JSONModel()
{
    delete m_rootItem;
}

QModelIndex JSONModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();

    JSONItem *parentItem;
    if (!parent.isValid())
        parentItem = m_rootItem;
    else
        parentItem = static_cast<JSONItem*>(parent.internalPointer());

    JSONItem *childItem = parentItem->child(row);
    if (childItem)
        return createIndex(row, column, childItem);
    return QModelIndex();
}

QModelIndex JSONModel::parent(const QModelIndex &index) const
{
    if (!index.isValid())
        return QModelIndex();

    JSONItem *childItem = static_cast<JSONItem*>(index.internalPointer());
    JSONItem *parentItem = childItem->parent();

    if (parentItem == m_rootItem)
        return QModelIndex();

    return createIndex(parentItem->childNumber(), 0, parentItem);
}

int JSONModel::rowCount(const QModelIndex &parent) const
{
    JSONItem *parentItem;
    if (parent.column() > 0)
        return 0;

    if (!parent.isValid())
        parentItem = m_rootItem;
    else
        parentItem = static_cast<JSONItem*>(parent.internalPointer());

    return parentItem->childCount();
}

int JSONModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 2; // Key and Value columns
}

QVariant JSONModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    JSONItem *item = static_cast<JSONItem*>(index.internalPointer());
    return item->data(index.column(), role);
}

QVariant JSONModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
        switch (section) {
        case 0:
            return tr("Key");
        case 1:
            return tr("Value");
        default:
            return QVariant();
        }
    }
    return QVariant();
}

Qt::ItemFlags JSONModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

void JSONModel::loadJSON(const QJsonDocument &document)
{
    beginResetModel();
    
    delete m_rootItem;
    m_rootItem = new JSONItem(QJsonValue(), nullptr);
    
    m_document = document;
    m_isValid = true;
    m_errorMessage.clear();
    
    if (!document.isNull()) {
        if (document.isObject()) {
            setupModelData(document.object(), m_rootItem);
        } else if (document.isArray()) {
            setupModelData(document.array(), m_rootItem);
        }
    }
    
    endResetModel();
    emit jsonLoaded();
}

void JSONModel::loadJSON(const QString &jsonString)
{
    QJsonParseError error;
    QJsonDocument document = QJsonDocument::fromJson(jsonString.toUtf8(), &error);
    
    if (error.error != QJsonParseError::NoError) {
        m_isValid = false;
        m_errorMessage = error.errorString();
        emit errorOccurred(m_errorMessage);
        return;
    }
    
    loadJSON(document);
}

void JSONModel::clear()
{
    beginResetModel();
    
    delete m_rootItem;
    m_rootItem = new JSONItem(QJsonValue(), nullptr);
    m_document = QJsonDocument();
    m_isValid = false;
    m_errorMessage.clear();
    
    endResetModel();
    emit jsonCleared();
}

bool JSONModel::isEmpty() const
{
    return m_rootItem->childCount() == 0;
}

QString JSONModel::getRawJSON() const
{
    if (m_document.isNull())
        return QString();
    
    return m_document.toJson(QJsonDocument::Indented);
}

QJsonDocument JSONModel::getDocument() const
{
    return m_document;
}

JSONItem* JSONModel::getItem(const QModelIndex &index) const
{
    if (!index.isValid())
        return m_rootItem;
    
    return static_cast<JSONItem*>(index.internalPointer());
}

QModelIndex JSONModel::findKey(const QString &key, const QModelIndex &startFrom) const
{
    if (!startFrom.isValid())
        return QModelIndex();
    
    JSONItem *item = static_cast<JSONItem*>(startFrom.internalPointer());
    if (item->getKey() == key)
        return startFrom;
    
    // Search in children
    for (int i = 0; i < item->childCount(); ++i) {
        QModelIndex childIndex = index(i, 0, startFrom);
        QModelIndex found = findKey(key, childIndex);
        if (found.isValid())
            return found;
    }
    
    return QModelIndex();
}

void JSONModel::expandAll()
{
    if (!m_rootItem) return;
    
    // Clear all expansion states first
    m_expandedItems.clear();
    
    // Create the same mapping as in getFlatListWithExpansion
    QMap<JSONItem*, int> itemToIndex;
    int globalIndex = 0;
    
    std::function<void(JSONItem*)> assignIndices = [&](JSONItem *item) {
        if (!item) return;
        itemToIndex[item] = globalIndex++;
        
        for (int i = 0; i < item->childCount(); ++i) {
            assignIndices(item->child(i));
        }
    };
    
    // Assign indices to all items
    for (int i = 0; i < m_rootItem->childCount(); ++i) {
        assignIndices(m_rootItem->child(i));
    }
    
    // Mark all items with children as expanded
    std::function<void(JSONItem*)> markExpandable = [&](JSONItem *item) {
        if (!item) return;
        
        if (item->childCount() > 0) {
            int itemIndex = itemToIndex[item];
            m_expandedItems.insert(itemIndex);
        }
        
        // Recursively mark all children
        for (int i = 0; i < item->childCount(); ++i) {
            markExpandable(item->child(i));
        }
    };
    
    // Start with root children
    for (int i = 0; i < m_rootItem->childCount(); ++i) {
        markExpandable(m_rootItem->child(i));
    }
    
    emit layoutChanged();
}

void JSONModel::collapseAll()
{
    m_expandedItems.clear();
    emit layoutChanged();
}

QVariantList JSONModel::getFlatList() const
{
    return getFlatListWithExpansion(-1);
}

QVariantList JSONModel::getFlatListWithExpansion(int maxDepth) const
{
    QVariantList flatList;
    
    if (!m_rootItem) {
        return flatList;
    }
    
    // Create a mapping from JSONItem* to a unique index
    QMap<JSONItem*, int> itemToIndex;
    int globalIndex = 0;
    
    // First pass: assign unique indices to all items
    std::function<void(JSONItem*)> assignIndices = [&](JSONItem *item) {
        if (!item) return;
        itemToIndex[item] = globalIndex++;
        
        for (int i = 0; i < item->childCount(); ++i) {
            assignIndices(item->child(i));
        }
    };
    
    // Assign indices to all items
    // If the root has only one child and it's an array, include the array itself
    if (m_rootItem->childCount() == 1 && m_rootItem->child(0)->getValue().isArray()) {
        // For arrays, include the array itself and its children
        JSONItem* arrayItem = m_rootItem->child(0);
        assignIndices(arrayItem); // Include the array itself
        for (int i = 0; i < arrayItem->childCount(); ++i) {
            assignIndices(arrayItem->child(i));
        }
    } else {
        // For objects or other structures, start from root children
        for (int i = 0; i < m_rootItem->childCount(); ++i) {
            assignIndices(m_rootItem->child(i));
        }
    }
    
    // Second pass: build flat list respecting expansion states
    std::function<void(JSONItem*, int)> flattenItems = [&](JSONItem *item, int depth) {
        if (!item) return;
        if (maxDepth >= 0 && depth > maxDepth) return; // respect depth cap
        
        int itemIndex = itemToIndex[item];
        
        // Add current item to flat list
        QVariantMap itemData;
        itemData["key"] = item->getKey();
        
        // Handle different value types properly
        QJsonValue value = item->getValue();
        QString valueStr;
        switch (value.type()) {
        case QJsonValue::Null:
            valueStr = "null";
            break;
        case QJsonValue::Bool:
            valueStr = value.toBool() ? "true" : "false";
            break;
        case QJsonValue::Double:
            valueStr = QString::number(value.toDouble());
            break;
        case QJsonValue::String:
            valueStr = value.toString();
            break;
        case QJsonValue::Array:
        case QJsonValue::Object:
            valueStr = ""; // Objects and arrays don't have direct values
            break;
        default:
            valueStr = value.toString();
            break;
        }
        itemData["value"] = valueStr;
        
        // Debug logging (removed to prevent crashes)
        
        itemData["type"] = static_cast<int>(value.type());
        itemData["depth"] = depth;
        itemData["hasChildren"] = item->childCount() > 0;
        itemData["expanded"] = m_expandedItems.contains(itemIndex);
        itemData["index"] = itemIndex;
        flatList.append(itemData);
        
        // Add children only if this item is expanded
        // For root array items, always show children
        bool shouldShowChildren = m_expandedItems.contains(itemIndex) || 
                                 (depth == 1 && item->getValue().isObject()); // Always show children for root array items that are objects
        
        if (shouldShowChildren && item->childCount() > 0) {
            for (int i = 0; i < item->childCount(); ++i) {
                flattenItems(item->child(i), depth + 1);
            }
        }
    };
    
    // Start with root children (skip the root itself)
    // If the root has only one child and it's an array, show the array as root
    if (m_rootItem->childCount() == 1 && m_rootItem->child(0)->getValue().isArray()) {
        // For arrays, show the array itself as the root item
        JSONItem* arrayItem = m_rootItem->child(0);
        int arrayIndex = itemToIndex[arrayItem];
        
        // Add the array as root item
        QVariantMap rootData;
        rootData["key"] = "Array[" + QString::number(arrayItem->childCount()) + "]";
        rootData["value"] = "";
        rootData["type"] = static_cast<int>(QJsonValue::Array);
        rootData["depth"] = 0;
        rootData["hasChildren"] = arrayItem->childCount() > 0;
        rootData["expanded"] = true; // Always show root array as expanded
        rootData["index"] = arrayIndex;
        flatList.append(rootData);
        
        // Add array children (always show them for root array)
        for (int i = 0; i < arrayItem->childCount(); ++i) {
            flattenItems(arrayItem->child(i), 1);
        }
    } else {
        // For objects or other structures, start from root children
        for (int i = 0; i < m_rootItem->childCount(); ++i) {
            flattenItems(m_rootItem->child(i), 0);
        }
    }
    
    return flatList;
}

void JSONModel::setItemExpanded(int index, bool expanded)
{
    qDebug() << "JSONModel::setItemExpanded called with index:" << index << "expanded:" << expanded;
    if (expanded) {
        m_expandedItems.insert(index);
        qDebug() << "Added index" << index << "to expanded items. Total expanded:" << m_expandedItems.size();
    } else {
        m_expandedItems.remove(index);
        qDebug() << "Removed index" << index << "from expanded items. Total expanded:" << m_expandedItems.size();
    }
    emit layoutChanged();
    qDebug() << "Emitted layoutChanged signal";
}

bool JSONModel::isItemExpanded(int index) const
{
    return m_expandedItems.contains(index);
}

bool JSONModel::isValidJSON() const
{
    return m_isValid;
}

QString JSONModel::getErrorMessage() const
{
    return m_errorMessage;
}

int JSONModel::getTotalItems() const
{
    int count = 0;
    std::function<void(JSONItem*)> countItems = [&](JSONItem *item) {
        count++;
        for (int i = 0; i < item->childCount(); ++i) {
            countItems(item->child(i));
        }
    };
    
    countItems(m_rootItem);
    return count - 1; // Exclude root item
}

int JSONModel::getMaxDepth() const
{
    int maxDepth = 0;
    std::function<void(JSONItem*, int)> findDepth = [&](JSONItem *item, int depth) {
        maxDepth = qMax(maxDepth, depth);
        for (int i = 0; i < item->childCount(); ++i) {
            findDepth(item->child(i), depth + 1);
        }
    };
    
    findDepth(m_rootItem, 0);
    return maxDepth;
}

void JSONModel::setupModelData(const QJsonValue &value, JSONItem *parent)
{
    if (value.isObject()) {
        QJsonObject obj = value.toObject();
        for (auto it = obj.begin(); it != obj.end(); ++it) {
            JSONItem *item = createItem(it.value(), parent);
            item->setKey(it.key());
            parent->appendChild(item);
        }
    } else if (value.isArray()) {
        QJsonArray arr = value.toArray();
        for (int i = 0; i < arr.size(); ++i) {
            JSONItem *item = createItem(arr.at(i), parent);
            item->setKey(QString("[%1]").arg(i));
            parent->appendChild(item);
        }
    }
}

JSONItem* JSONModel::createItem(const QJsonValue &value, JSONItem *parent)
{
    JSONItem *item = new JSONItem(value, parent);
    
    if (value.isObject() || value.isArray()) {
        setupModelData(value, item);
    }
    
    return item;
}

QString JSONModel::formatValue(const QJsonValue &value) const
{
    switch (value.type()) {
    case QJsonValue::Null:
        return "null";
    case QJsonValue::Bool:
        return value.toBool() ? "true" : "false";
    case QJsonValue::Double:
        return QString::number(value.toDouble());
    case QJsonValue::String:
        return QString("\"%1\"").arg(value.toString());
    case QJsonValue::Array:
        return QString("[%1 items]").arg(value.toArray().size());
    case QJsonValue::Object:
        return QString("{%1 items}").arg(value.toObject().size());
    default:
        return "unknown";
    }
}

QIcon JSONModel::getIconForType(QJsonValue::Type type) const
{
    // Return appropriate icons for different JSON types
    // For now, return empty icon - can be enhanced later
    return QIcon();
}

// JSONItem Implementation
JSONItem::JSONItem(const QJsonValue &value, JSONItem *parent)
    : m_parentItem(parent)
    , m_value(value)
    , m_expanded(false)
{
    setupChildren();
}

JSONItem::~JSONItem()
{
    qDeleteAll(m_childItems);
}

QVariant JSONItem::data(int column, int role) const
{
    switch (role) {
    case Qt::DisplayRole:
        if (column == 0) {
            return m_key;
        } else if (column == 1) {
            return getFormattedValue();
        }
        break;
    case Qt::DecorationRole:
        if (column == 0) {
            return getIconForType(m_value.type());
        }
        break;
    case Qt::FontRole:
        if (column == 0 && (m_value.isObject() || m_value.isArray())) {
            QFont font;
            font.setBold(true);
            return font;
        }
        break;
    case Qt::ForegroundRole:
        if (column == 1) {
            switch (m_value.type()) {
            case QJsonValue::String:
                return QColor(0, 128, 0); // Green for strings
            case QJsonValue::Double:
                return QColor(0, 0, 255); // Blue for numbers
            case QJsonValue::Bool:
                return QColor(255, 0, 0); // Red for booleans
            case QJsonValue::Null:
                return QColor(128, 128, 128); // Gray for null
            default:
                return QVariant();
            }
        }
        break;
    }
    
    return QVariant();
}

void JSONItem::setData(const QVariant &value, int role)
{
    Q_UNUSED(value)
    Q_UNUSED(role)
    // Read-only for now
}

JSONItem* JSONItem::child(int number)
{
    if (number < 0 || number >= m_childItems.size())
        return nullptr;
    return m_childItems.at(number);
}

int JSONItem::childCount() const
{
    return m_childItems.size();
}

int JSONItem::columnCount() const
{
    return 2;
}

JSONItem* JSONItem::parent()
{
    return m_parentItem;
}

int JSONItem::childNumber() const
{
    if (m_parentItem) {
        return m_parentItem->m_childItems.indexOf(const_cast<JSONItem*>(this));
    }
    return 0;
}

QString JSONItem::getKey() const
{
    return m_key;
}

void JSONItem::setKey(const QString &key)
{
    m_key = key;
}

QJsonValue JSONItem::getValue() const
{
    return m_value;
}

void JSONItem::setValue(const QJsonValue &value)
{
    m_value = value;
}

QJsonValue::Type JSONItem::getType() const
{
    return m_value.type();
}

QString JSONItem::getTypeString() const
{
    switch (m_value.type()) {
    case QJsonValue::Null:
        return "null";
    case QJsonValue::Bool:
        return "boolean";
    case QJsonValue::Double:
        return "number";
    case QJsonValue::String:
        return "string";
    case QJsonValue::Array:
        return "array";
    case QJsonValue::Object:
        return "object";
    default:
        return "unknown";
    }
}

QString JSONItem::getFormattedValue() const
{
    return formatValue(m_value);
}

bool JSONItem::isExpanded() const
{
    return m_expanded;
}

void JSONItem::setExpanded(bool expanded)
{
    m_expanded = expanded;
}

void JSONItem::appendChild(JSONItem *child)
{
    m_childItems.append(child);
}

void JSONItem::removeChild(int index)
{
    if (index >= 0 && index < m_childItems.size()) {
        delete m_childItems.takeAt(index);
    }
}

void JSONItem::clearChildren()
{
    qDeleteAll(m_childItems);
    m_childItems.clear();
}

int JSONItem::getDepth() const
{
    int depth = 0;
    JSONItem *parent = m_parentItem;
    while (parent) {
        depth++;
        parent = parent->m_parentItem;
    }
    return depth;
}

QString JSONItem::getPath() const
{
    QStringList pathParts;
    JSONItem *current = const_cast<JSONItem*>(this);
    
    while (current && current->m_parentItem) {
        pathParts.prepend(current->m_key);
        current = current->m_parentItem;
    }
    
    return pathParts.join(".");
}

void JSONItem::setupChildren()
{
    if (m_value.isObject()) {
        QJsonObject obj = m_value.toObject();
        for (auto it = obj.begin(); it != obj.end(); ++it) {
            JSONItem *child = new JSONItem(it.value(), this);
            child->setKey(it.key());
            m_childItems.append(child);
        }
    } else if (m_value.isArray()) {
        QJsonArray arr = m_value.toArray();
        for (int i = 0; i < arr.size(); ++i) {
            JSONItem *child = new JSONItem(arr.at(i), this);
            child->setKey(QString("[%1]").arg(i));
            m_childItems.append(child);
        }
    }
}

QString JSONItem::formatValue(const QJsonValue &value) const
{
    switch (value.type()) {
    case QJsonValue::Null:
        return "null";
    case QJsonValue::Bool:
        return value.toBool() ? "true" : "false";
    case QJsonValue::Double:
        return QString::number(value.toDouble());
    case QJsonValue::String:
        return QString("\"%1\"").arg(value.toString());
    case QJsonValue::Array:
        return QString("[%1 items]").arg(value.toArray().size());
    case QJsonValue::Object:
        return QString("{%1 items}").arg(value.toObject().size());
    default:
        return "unknown";
    }
}

QIcon JSONItem::getIconForType(QJsonValue::Type type) const
{
    // Return appropriate icons for different JSON types
    // For now, return empty icon - can be enhanced later
    return QIcon();
}

} // namespace treon
