import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5 as QC

Rectangle {
   id: loadingScreen
   anchors.fill: parent
   color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
   z: 1000

   MouseArea {
      anchors.fill: parent
   }

   property double spacing: units.gu(2)

   Rectangle {
      id: loadingContent
      color: "white"
      radius: 10
      anchors.centerIn: parent
      width: parent.width * 0.8
      height: units.gu(24)

      Column {
         anchors.centerIn: parent
         spacing: units.gu(2)

         QC.BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: true
         }

         Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Plant is being identified, please wait.")
            wrapMode: Text.WordWrap
         }
      }
   }
}
