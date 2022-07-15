import QtQuick 2.7
import Ubuntu.Components 1.3 as UC

Rectangle {
   id: rect
   radius: units.gu(1)
   clip: true
   color: pressed ? "#575757" : "#666666"

   property bool pressed: false
   property double widthGu: 4
   property double heightGu: 4
   property string iconName
   property var onClicked

   width: units.gu(widthGu)
   height: units.gu(heightGu)

   MouseArea {
      z: icon.z+1
      anchors.fill: parent
      onClicked: {
         if (rect.onClicked) {
            rect.onClicked()
         }
      }

      onPressed: rect.pressed = true
      onReleased: rect.pressed = false
   }

   UC.Icon {
      id: icon
      name: rect.iconName
      anchors.centerIn: parent
      width: units.gu(rect.widthGu-1.0)
      height: units.gu(rect.heightGu-1.0)
      color: "#f7f7f7"
   }
}