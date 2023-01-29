import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Lomiri.Content 1.1
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
   property string subText
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

   Image {
      id: thumbImage
      width: units.gu(8)
      height: units.gu(8)
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      visible: !item.placeholder

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

   Column {
      visible: !item.placeholder && item.listMode
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: thumbImage.right
      anchors.leftMargin: units.gu(2)
      anchors.right: deleteButton.left
      anchors.rightMargin: units.gu(2)
      spacing: units.gu(1)

      Text {
         visible: item.listMode
         text: item.mainText
         width: parent.width
         elide: Text.ElideRight
         font.bold: true
         color: "white"
      }

      Text {
         visible: item.listMode
         text: item.subText
         width: parent.width
         elide: Text.ElideRight
         color: "white"
      }
   }

   Column {
      visible: !item.placeholder && !item.listMode
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: thumbImage.right
      anchors.leftMargin: units.gu(2)
      anchors.right: editButton.left
      anchors.rightMargin: units.gu(2)
      spacing: units.gu(1)

      Text {
         text: i18n.tr("Organ")
         width: parent.width
         elide: Text.ElideRight
         font.bold: true
         color: "white"
      }

      Text {
         text: item.mainText
         width: parent.width
         elide: Text.ElideRight
         color: "white"
      }
   }

   IconButton {
      id: editButton
      anchors.right: deleteButton.left
      anchors.rightMargin: units.gu(2)
      anchors.verticalCenter: parent.verticalCenter
      widthGu: 4.0
      heightGu: 4.0
      visible: !item.listMode && !item.placeholder
      iconName: "compose"

      onClicked: function() {
         if (item.onEdit)
            item.onEdit()
      }
   }

   IconButton {
      id: deleteButton
      anchors.right: parent.right
      anchors.rightMargin: units.gu(2)
      anchors.verticalCenter: parent.verticalCenter
      widthGu: 4.0
      heightGu: 4.0
      visible: !item.placeholder
      iconName: "delete"

      onClicked: function() {
         if (item.onDelete)
            item.onDelete(item.plantObject && item.plantObject.id)
      }
   }
}
