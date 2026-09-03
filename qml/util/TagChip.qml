import QtQuick 2.7
import Lomiri.Components 1.3

Rectangle {
   id: chip

   property string tagText: ""
   property bool removable: false
   property bool selected: false
   property var onClicked: null
   property var onRemove: null

   readonly property bool highlighted: removable || selected

   radius: height / 2
   color: highlighted ? "#669900" : "#e8e8e8"
   border.width: highlighted ? 0 : 1
   border.color: "#cdcdcd"
   width: row.width + units.gu(2)
   height: units.gu(3.5)

   Row {
      id: row
      anchors.centerIn: parent
      spacing: units.gu(0.5)

      Text {
         anchors.verticalCenter: parent.verticalCenter
         text: chip.tagText
         color: chip.highlighted ? "white" : "#232323"
      }

      Text {
         visible: chip.removable
         anchors.verticalCenter: parent.verticalCenter
         text: "✕"
         color: "white"

         MouseArea {
            anchors.fill: parent
            anchors.margins: -units.gu(1)
            onClicked: if (chip.onRemove) chip.onRemove()
         }
      }
   }

   MouseArea {
      anchors.fill: parent
      enabled: !chip.removable
      onClicked: if (chip.onClicked) chip.onClicked()
   }
}
