import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Content 1.1
import QtGraphicalEffects 1.12

import "../util"

Rectangle {
   id: item

   property var plantObject
   property string imageUrl
   property var onDelete
   property var onEdit
   property var onClicked
   property string mainText
   property bool listMode: true
   property bool placeholder: false
   property double spacing: units.gu(1)

   width: parent.width
   height: units.gu(8)
   radius: 10
   color: placeholder ? "white" : "#669900"
   border.width: placeholder ? 2 : 0
   border.color: "#cdcdcd"

   MouseArea {
      anchors.fill: parent
      enabled: item.listMode || item.placeholder

      onClicked: {
         if (item.onClicked)
            item.onClicked(item.plantObject)
      }
   }

   Icon {
      visible: item.placeholder
      name: "add"
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: units.gu(2)

      width: units.gu(2)
      height: units.gu(2)
   }

   Text {
      visible: item.placeholder
      anchors.centerIn: parent
      text: i18n.tr("Tap to add new image")
      color: "#676767"
   }

   Row {
      visible: !item.placeholder
      anchors.verticalCenter: parent.verticalCenter
      spacing: item.spacing

      Image {
         id: thumbImage
         width: units.gu(8)
         height: units.gu(8)
         source: item.imageUrl
         fillMode: Image.PreserveAspectCrop
         layer.enabled: true
         layer.effect: OpacityMask {
            maskSource: Item {
               width: thumbImage.width
               height: thumbImage.height

               Rectangle {
                  anchors.centerIn: parent
                  width: Math.min(thumbImage.width, thumbImage.height)
                  height: width
                  radius: 10
               }
            }
         }
      }

      Text {
         visible: item.listMode
         anchors.verticalCenter: parent.verticalCenter
         text: item.mainText
         color: "white"
      }

      Column {
         visible: !item.listMode
         anchors.verticalCenter: parent.verticalCenter

         Text {
            text: i18n.tr("Organ")
            font.bold: true
            color: "white"
         }

         Text {
            width: item.width - units.gu(16) - 4 * item.spacing
            text: item.mainText
            color: "white"
         }
      }
   }

   Button {
      width: units.gu(4)
      height: units.gu(4)
      anchors.right: closeButton.left
      anchors.rightMargin: units.gu(2)
      anchors.verticalCenter: parent.verticalCenter
      visible: !item.listMode && !item.placeholder
      iconName: "compose"

      onClicked: {
         if (item.onEdit)
            item.onEdit()
      }
   }

   Button {
      id: closeButton
      width: units.gu(4)
      height: units.gu(4)
      anchors.right: parent.right
      anchors.rightMargin: units.gu(2)
      anchors.verticalCenter: parent.verticalCenter
      visible: !item.placeholder
      iconName: "delete"

      onClicked: {
         if (item.onDelete)
            item.onDelete(item.plantObject && item.plantObject.id)
      }
   }
}
