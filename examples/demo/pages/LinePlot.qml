import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml 2.15
import QtQuickPlotScene as QtQuickPlotScene

/**
  XYPlot example
  */

Page {
    id: root
//    layer.enabled: true
//    layer.samples: 8

//    Timer{
//       interval: 1
//       onTriggered: linePlot.coordinates = generateTestCoords()
//       running: true
//       repeat: false

//    }

    ColumnLayout {
        anchors.fill: parent
        anchors.rightMargin: 5
        // Plot axes for XY plot demonstration
        QtQuickPlotScene.Axes {
            Layout.fillHeight: true
            Layout.fillWidth: true
            xLabel: "X Axis"
            yLabel: "Y Axis"
            // Define plot group containing zoom/pan tool and XY plot item
            plotGroup: QtQuickPlotScene.PlotGroup {
                //viewRect: Qt.rect(-1, -.1, 2, 1.2)
                id: plotGroup
                logY: logSwitch.checked

                clip: true
               //viewMode: 2
                plotItems: [
                    QtQuickPlotScene.ZoomPanTool {
                        id:zoomPantool
                        Connections{
                            target: approot
                            enabled: scrollSwitch.checked
                            property real counter: 0
                            function onBeforeRendering() {
                                zoomPantool.pan(0.001,0);
                            }
                        }
                        maxViewRect: Qt.rect(-200000., -100000., 4000000., 3000000.)
                        minimumSize: Qt.size(0.1, 0.1)
                    },
                    // Line plot item with some test data
                    QtQuickPlotScene.LinePlot {
                        id: linePlot
                        lineColor: "red"
                        lineWidth: lineWidthSlider.value


                        Connections{
                            target: approot
                            enabled:appendSwitch.checked
                            property real counter: 0
                            function onBeforeRendering() {
                                linePlot.update()
                                linePlot.append(counter/1000, Math.sin(counter/100))
                                counter++
                            }
                        }

                    },
                    QtQuickPlotScene.LinePlot {
                        id: linePlot2
                        lineColor: "green"
                        lineWidth: lineWidthSlider.value


                        Connections{
                            target: approot
                             enabled:appendSwitch.checked
                            property real counter: 0
                            function onBeforeRendering() {
                                linePlot2.update()
                                linePlot2.append(counter/1000, Math.sin((counter/100)+1))
                                counter++
                            }
                        }

                    },
                    QtQuickPlotScene.LinePlot {
                        id: linePlot3
                        lineColor: "blue"
                        lineWidth: lineWidthSlider.value


                        Connections{
                            target: approot
                             enabled:appendSwitch.checked
                            property real counter: 0
                            function onBeforeRendering() {
                                linePlot3.update()
                                linePlot3.append(counter/1000, Math.sin((counter/100)+2))
                                counter++
                            }
                        }

                    },
                    QtQuickPlotScene.LinePlot {
                        id: linePlot4
                        lineColor: "magenta"
                        lineWidth: lineWidthSlider.value


                        Connections{
                            target: approot
                            enabled:appendSwitch.checked
                            property real counter: 0
                            function onBeforeRendering() {
                                linePlot4.update()
                                linePlot4.append(counter/1000, Math.sin((counter/100)+3))
                                counter++
                            }
                        }

                    }

                ]
            }
        }
        // Controls for changing plot properties
        RowLayout {
            Layout.margins: Qt.application.font.pixelSize
            spacing: Qt.application.font.pixelSize / 2
            // Change hue values
            Slider {
                id: hueSlider
                readonly property real hue: value * (1. / to)
                from: 0; to: 100; stepSize: 1; value: 55
                ToolTip.visible: hovered || pressed
                ToolTip.text: "Hue value"
            }
            // Change line width
            Slider {
                id: lineWidthSlider
                from: 1; to: 10; stepSize: 1; value: 3
                ToolTip.visible: hovered || pressed
                ToolTip.text: "Line width " + value
            }
            Text{
                text: " number of points : " +linePlot.coordinates.length
            }
            Switch{
                id: logSwitch
                text: "Logarithmic"
                checked: false
            }
            Switch{
                id: appendSwitch
                text: "enable append"
                checked: true
            }
            Switch{
                id: scrollSwitch
                text: "enable Scrolling"
                checked: true
            }
        }
    }
}
