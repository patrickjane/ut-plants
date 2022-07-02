import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Content 1.1
import QtGraphicalEffects 1.12

import "../util"

UbuntuShape {
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

   width: parent.width; height: units.gu(8)
   radius: "small"
   color: placeholder ? theme.palette.normal.raised : UbuntuColors.green
//    border.width: placeholder ? 2 : 0
//    border.color: "#cdcdcd"
   aspect: placeholder ? UbuntuShape.Inset : UbuntuShape.DropShadow

   MouseArea {
      anchors.fill: parent
      enabled: item.listMode || item.placeholder

      onClicked: {
         if (item.onClicked)
            item.onClicked(item.plantObject);
      }
   }

   Icon {
      visible: item.placeholder
      name: "add"

      anchors {
         verticalCenter: parent.verticalCenter
         left: parent.left
         leftMargin: units.gu(2)
      }

      width: units.gu(2); height: width
   }

   Text {
      text: i18n.tr("Tap to add new image")

      visible: item.placeholder
      anchors.centerIn: parent
      color: "#676767"
   }

   Row {
      visible: !item.placeholder
      anchors.verticalCenter: parent.verticalCenter
      spacing: item.spacing

      Image {
         id: thumbImage
         width: units.gu(8); height: width

         source: item.imageUrl
         fillMode: Image.PreserveAspectCrop

         layer.enabled: true
         layer.effect: OpacityMask {
            maskSource: Item {
               width: thumbImage.width; height: thumbImage.height

               Rectangle {
                  anchors.centerIn: parent
                  width: Math.min(thumbImage.width, thumbImage.height); height: width
                  radius: 10
               }
            }
         }
      }

      Text {
         text: item.mainText
         visible: item.listMode
         anchors.verticalCenter: parent.verticalCenter
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
            width: item.width - units.gu(16) - 4*item.spacing
            text: item.mainText
            color: "white"
         }
      }
   }

   Button {
      width: units.gu(4); height: width

      anchors {
         right: closeButton.left
         rightMargin: units.gu(2)
         verticalCenter: parent.verticalCenter
      }
      visible: !item.listMode && !item.placeholder

      iconName: "compose"
      color: UbuntuColors.graphite
      //color: "transparent"

      TapHandler {
         onTapped: {
            if (item.onEdit)
               item.onEdit()
         }
      }
   }

   Button {
      id: closeButton

      width: units.gu(4); height: width

      anchors {
         right: parent.right
         rightMargin: units.gu(2)
         verticalCenter: parent.verticalCenter
      }

      visible: !item.placeholder
      iconName: "delete"
      color: theme.palette.normal.negative

      onClicked: {
         if (item.onDelete)
            item.onDelete(item.plantObject && item.plantObject.id);
      }
   }
}
