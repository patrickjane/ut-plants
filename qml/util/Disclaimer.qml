import QtQuick 2.0
import Lomiri.Components 1.3
import Qt.labs.settings 1.0

import "../util"

Rectangle {
   property int padding: parent.width * 0.05
   property int paddingMedium: units.gu(2)

   Settings {
      id: settings
      property bool disclaimerAccepted: false
   }

   id: appDisclaimer
   anchors.verticalCenter: parent.verticalCenter
   anchors.horizontalCenter: parent.horizontalCenter
   width: parent.width * 0.8
   height: childrenRect.height

   visible: false
   radius: 8
   z: 200

   border.width: 1
   border.color: "#cdcdcd"

   Column {
      anchors.top: parent.top
      anchors.topMargin: padding
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width - 2*padding
      spacing: padding

      Text {
         anchors.horizontalCenter: parent.horizontalCenter
         font.pointSize: units.gu(2)
         color: "#232323"
         text: "Disclaimer"
      }

      Text {
         anchors.horizontalCenter: parent.horizontalCenter
         font.pointSize: units.gu(1)
         wrapMode: Text.WordWrap
         width: parent.width

         color: "#232323"
         text: i18n.tr("This app uses the online service of Pl@ntNet (plantnet.org) to identify plants. Photos will be uploaded to Pl@ntNet for recognition, and the result will show a probability of correctness. This means, results provided by the service could be wrong, or some plants can maybe not be identified at all.")
      }

      Button {
         anchors.horizontalCenter: parent.horizontalCenter
         color: "black"
         text: i18n.tr("Accept")
         onClicked: {
            settings.disclaimerAccepted = true
            appDisclaimer.visible = false
         }
      }

      Rectangle {
         id: spacer
         color: "transparent"
         width: parent.width
         height: units.gu(2)
      }
   }
}
