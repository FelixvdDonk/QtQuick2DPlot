import QtQuick
import QtQuickPlotScene as QtQuickPlotScene

// TODO: Better move calculations to C++?

Item {
    id: root

    property Item plotGroup: parent
    property double infinityApprox: Number.POSITIVE_INFINITY

    readonly property bool pressed: mouseArea.pressed || mouseArea.wheelActive || pinchArea.pressed

    property rect maxViewRect: Qt.rect(-infinityApprox, -infinityApprox, infinityApprox, infinityApprox)
    property size minimumSize: Qt.size(0, 0)
    property size maximumSize: Qt.size(maxViewRect.width, maxViewRect.height)

    function pan(x,y){
        let viewRect = root.plotGroup.viewRect;
        let newViewRect = Qt.rect(viewRect.x+x,viewRect.y+y, viewRect.width,viewRect.height);
        root.plotGroup.viewRect = newViewRect;
    }

    function scaleSizeVarAspect(oldSize, scaleX, scaleY) {
        let width = Math.max(Math.min(oldSize.width*scaleX, maximumSize.width), minimumSize.width);
        let height = Math.max(Math.min(oldSize.height*scaleY, maximumSize.height), minimumSize.height);
        return Qt.size(width, height);
    }

    function scaleSizeFixAspect(oldSize, scale) {
        let scaleX = Math.max(Math.min(oldSize.width*scale, maximumSize.width), minimumSize.width) / oldSize.width;
        let scaleY = Math.max(Math.min(oldSize.height*scale, maximumSize.height), minimumSize.height) / oldSize.height;
        // TODO: Allow chosing between different clip/expand policies?
        let scaleMax = Math.max(scaleX, scaleY);
        return Qt.size(oldSize.width * scaleMax, oldSize.height * scaleMax);
    }

    function moveToMaxView(rect) {
        let x, y;
        // Adjust view to valid position or center view if size exceeds limit
        if (rect.width > maxViewRect.width) {
            x = maxViewRect.x + (maxViewRect.width - rect.width) * .5;
        } else {
            let xMax = (maxViewRect.width === infinityApprox) ? infinityApprox : maxViewRect.x + maxViewRect.width - rect.width;
            x = Math.min(Math.max(rect.x, maxViewRect.x), xMax);
        }
        if (rect.height > maxViewRect.height) {
            y = maxViewRect.y + (maxViewRect.height - rect.height) * .5;
        } else {
            let yMax = (maxViewRect.height === infinityApprox) ? infinityApprox : maxViewRect.y + maxViewRect.height - rect.height;
            y = Math.min(Math.max(rect.y, maxViewRect.y), yMax);
        }
        return Qt.rect(x, y, rect.width, rect.height);
    }

    // Mouse/Pinch area for zooming and panning viewRect
    PinchArea {
        id: pinchArea
        enabled: root.enabled
        property bool pressed: false
        anchors.fill: parent
        onPinchStarted: { pressed = true; }
        onPinchFinished: { pressed = false; }
        onPinchUpdated: {
            // TODO: Check new coordinate transform on touch device
            // TODO: Apply constraints
            let viewRect = root.plotGroup.viewRect;
            let newViewRect = Qt.rect(viewRect.x, viewRect.y, viewRect.width, viewRect.height);
            // Calculate pinch center move in plot space
            let delta = Qt.point((pinch.center.x - pinch.previousCenter.x) * viewRect.width / root.width,
                                 (pinch.previousCenter.y - pinch.center.y) * viewRect.height / root.height);
            let scale = 1. / (1. + pinch.scale - pinch.previousScale);

            // Apply pan
            newViewRect.x -= delta.x;
            newViewRect.y -= delta.y;
            // Apply zoom
            newViewRect.x = newViewRect.x + pinch.center.x / root.width * newViewRect.width * (1. - scale);
            newViewRect.y = newViewRect.y + (root.height - pinch.center.y) / root.height * newViewRect.height * (1. - scale);
            newViewRect.width *= scale;
            newViewRect.height *= scale;
            root.plotGroup.viewRect = newViewRect;
        }

        MouseArea {
            id: mouseArea
            property bool wheelActive: false
            property point mouseOld: Qt.point(0, 0)
            property point pressedP: Qt.point(0, 0)
            property bool zoomMode: false
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
            enabled: root.enabled
            anchors.fill: parent

            onWheel: (wheel) => {
                let oldPos = Qt.point(root.plotGroup.viewRect.x, root.plotGroup.viewRect.y);
                let oldSize = Qt.size(root.plotGroup.viewRect.width, root.plotGroup.viewRect.height);
                let scale = 1. - wheel.angleDelta.y * (0.25 / 120.);
                const autoAspect = root.plotGroup.viewMode === QtQuickPlotScene.PlotGroup.AutoAspect;
                let newSize = autoAspect ? scaleSizeVarAspect(oldSize, scale, scale) : scaleSizeFixAspect(oldSize, scale);
                let x = oldPos.x + wheel.x/root.width * (oldSize.width - newSize.width);
                let y = oldPos.y + (1. - wheel.y/root.height) * (oldSize.height - newSize.height);
                let newRect = Qt.rect(x, y, newSize.width, newSize.height);
                wheelActive = true;
                root.plotGroup.viewRect = moveToMaxView(newRect);
                wheelActive = false;
            }
            onPressed: (mouse) => {
                // Store coordinates and set zoom/pan mode on mouse-down
                pressedP = Qt.point(mouse.x, mouse.y);
                mouseOld = Qt.point(mouse.x, mouse.y);
                zoomMode = pressedButtons & Qt.RightButton;
            }
            onPositionChanged: (mouse) => {
                let oldPos = Qt.point(root.plotGroup.viewRect.x, root.plotGroup.viewRect.y);
                let oldSize = Qt.size(root.plotGroup.viewRect.width, root.plotGroup.viewRect.height);
                // Calculate mouse delta in plot space
                let delta = Qt.point((mouse.x - mouseOld.x) * oldSize.width / root.width,
                                     (mouseOld.y - mouse.y) * oldSize.height / root.height);
                mouseOld = Qt.point(mouse.x, mouse.y);

                let newRect, x, y;
                if (zoomMode) {
                    // Zoom mode, scale view at mouse down coordinates
                    let newSize;
                    const autoAspect = root.plotGroup.viewMode === QtQuickPlotScene.PlotGroup.AutoAspect;
                    if (!autoAspect) {
                        let relDelta = Math.abs(delta.x) > Math.abs(delta.y) ? delta.x/oldSize.width : delta.y/oldSize.height;
                        let scale = 1. - 2. * relDelta;
                        newSize = scaleSizeFixAspect(oldSize, scale);
                    } else {
                        let scaleX = 1. - 2. * delta.x / oldSize.width;
                        let scaleY = 1. - 2. * delta.y / oldSize.height;
                        newSize = scaleSizeVarAspect(oldSize, scaleX, scaleY);
                    }
                    let pressedCoords = Qt.point(pressedP.x * oldSize.width / root.width,
                                                (root.height - pressedP.y) * oldSize.height / root.height);
                    x = oldPos.x + pressedCoords.x * (1. - newSize.width/oldSize.width);
                    y = oldPos.y + pressedCoords.y * (1. - newSize.height/oldSize.height);
                    newRect = Qt.rect(x, y, newSize.width, newSize.height);
                } else {
                    // Pan mode, move view according to mouse delta
                    x = oldPos.x - delta.x;
                    y = oldPos.y - delta.y;
                    newRect = Qt.rect(x, y, oldSize.width, oldSize.height);
                }
                root.plotGroup.viewRect = moveToMaxView(newRect);
            }
        }
    }
}
