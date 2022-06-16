import Ubuntu.Components 1.3
import QtQuick 2.7
import QtQuick.Layouts 1.3

import "../colors"

Rectangle {
   z: 1000
   id: notification
   property string notificationId: "notificationId"
   property bool expanded: false
   property var activeNotification

   anchors.top: parent.top
   anchors.topMargin: units.gu(1)
   anchors.horizontalCenter: parent.horizontalCenter

   width: parent.width - 2*units.gu(1)
   height: expanded ? units.gu(40) : units.gu(5.5)

   clip: true
   color: Colors.surfaceColor // "white"
   radius: 8
   border.width: 1
   border.color: Colors.borderColor // "#898989"
   visible: !!activeNotification

   Row {
      id: infoRow
      anchors.leftMargin: units.gu(1)
      anchors.rightMargin: units.gu(2)*2 + 64

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top

      height: units.gu(5.5)
      spacing: units.gu(1)
      clip: true

      Icon {
         anchors.verticalCenter: parent.verticalCenter
         width: units.gu(4)
         height: units.gu(4)
         color: notification.activeNotification && (notification.activeNotification.type === "warning"
               ? "orange"
               : (notification.activeNotification.type === "error" ? "red" : "green" ))
               || "white"

         name: notification.activeNotification && (notification.activeNotification.type === "warning"
               ? "dialog-warning-symbolic"
               : (notification.activeNotification.type === "error" ? "dialog-error-symbolic" : "info" ))
               || "info"
      }

      Button {
         anchors.verticalCenter: parent.verticalCenter
         width: units.gu(4)
         height: units.gu(4)
         color: "transparent"
         iconName: !notification.expanded ? "toolkit_chevron-ltr_3gu" : "down"
         onClicked: {
            notification.expanded = !notification.expanded
            Notify.skipAutoDismiss()
         }
      }

      Label {
         id: titleLabel
         anchors.verticalCenter: parent.verticalCenter
         text: notification.activeNotification && notification.activeNotification.title || ""
         color: Colors.mainText
         font.pointSize: units.gu(1.5)
         font.bold: true
      }

      Label {
         id: textLabel
         anchors.verticalCenter: parent.verticalCenter
         text: notification.activeNotification && notification.activeNotification.text || ""
         visible: !expanded
         color: Colors.mainText

         font.pointSize: units.gu(1.5)
      }
   }

   Rectangle {
      anchors.right: parent.right
      anchors.rightMargin: units.gu(1)
      anchors.top: parent.top
      anchors.topMargin: 1
      height: units.gu(5.5)-2
      width: units.gu(4)
      radius: 8
      color: Colors.surfaceColor

      Button {
         anchors.centerIn: parent
         width: units.gu(4)
         height: units.gu(4)
         color: Colors.borderColor // "#cdcdcd"
         iconName: "close"
         onClicked: Notify.dismiss()
      }
   }

   Flickable {
      anchors.top: infoRow.bottom
      anchors.leftMargin: units.gu(1)
      anchors.rightMargin: units.gu(1)
      anchors.left: parent.left
      anchors.right: parent.right

      height: units.gu(32)
      contentWidth: parent.width - units.gu(4)
      contentHeight: fullText.height
      visible: expanded
      clip: true

      Text {
         id: fullText
         text: notification.activeNotification && notification.activeNotification.text || ""
         font.pointSize: units.gu(1.5)
         width: parent.width - units.gu(4)
         wrapMode: Text.WordWrap
         color: Colors.mainText
         visible: expanded
      }
   }

   Component.onCompleted: {
      Notify.register(notification)
      activeNotification = Notify.activeNotification
   }

   function onNotification(notification) {
      activeNotification = notification
      expanded = false
   }
}
