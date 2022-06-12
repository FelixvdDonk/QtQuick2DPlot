import QtQuick

Item {
    id: root
    property rect viewRect
    property rect itemRect: Qt.rect(0, 0, 1, 1)

    default property alias contentItems: contentItem.children

    Item {
        id: contentItem
        readonly property real _xFactor: root.width / root.viewRect.width
        readonly property real _yFactor: root.height / root.viewRect.height
        width: root.itemRect.width * _xFactor
        height: root.itemRect.height * _yFactor
        x: (itemRect.x - viewRect.x) * _xFactor
        y: root.height - height - (root.itemRect.y - root.viewRect.y) * _yFactor

        onChildrenChanged:  {
            // Anchor children to container content item
            for (var i=0; i < children.length; ++i) {
                children[i].anchors.fill = contentItem;
            }
        }
    }
}
