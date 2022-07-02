import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Content 1.1
import QtQuick.Controls 2.5 as QC

import "../util"

Item {
   id: plantCard
   property bool resultView: false
   property var saveFunction: null
   property var plant: null
   property double elementSpacing: units.gu(2)

   Component.onCompleted: {
      plant.images.forEach(function(image) {
         resultImageModel.append(image)
      })
   }

   ListModel {
      id: resultImageModel
   }

   UbuntuShape {
      id: item
      width: parent.width * 0.8; height: parent.height
      anchors.centerIn: parent

      radius: "small"
      // color: UbuntuColors.green

      Column {
         id: contents

         anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: units.gu(1)
            rightMargin: units.gu(1)
            leftMargin: units.gu(1)
            bottom: saveButton.top
         }

         spacing: plantCard.elementSpacing

         Item {
            id: header
            width: parent.width; height: units.gu(4)

            Column {
               id: nameColumn
               anchors {
                  top: parent.top
                  left: parent.left
               }

               Text {
                  text: i18n.tr("Name")
                  font.bold: true
                  color: "white"
               }
               Text {
                  text: plant.species
                  color: "white"
               }
            }

            Row {
               anchors {
                  top: parent.top
                  right: parent.right
               }
               height: nameColumn.height

               spacing: units.gu(1)

               Icon {
                  anchors.verticalCenter: parent.verticalCenter

                  name: "image-quality"
                  color: "white"

                  width: units.gu(2); height: width
               }
               Text {
                  property int scoreValue: Math.round(plant.score*100)

                  text: scoreValue + "%"

                  anchors.verticalCenter: parent.verticalCenter
                  font.pixelSize: units.gu(2)
                  font.bold: true

                  color: scoreValue > 80 ? "white"
                     : (scoreValue > 50 ? UbuntuColors.orange : UbuntuColors.red)
               }
            }
         }

         Rectangle {
            width: parent.width
            height: 1
            color: "white"
         }

         ListView {
            id: resultImagesList

            anchors.left: parent.left
            width: parent.width; height: parent.height * 0.5

            model: resultImageModel

            clip: true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange

            delegate: Component {
               Item {
                  width: resultImagesList.width; height: resultImagesList.height

                  Image {
                     source: prepareImageUrl(url)
                     width: parent.width; height: parent.height
                     asynchronous: true

                     fillMode: Image.PreserveAspectCrop
                  }

                  Text {
                     color: "white"
                     text: copyright
                     font.pixelSize: units.gu(1)
                  }
               }
            }
         }

         QC.PageIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: resultImagesList.currentIndex
            count: resultImagesList.count
         }

         Text {
            color: "white"
            text: i18n.tr("Common names")
            font.bold: true
         }

         Text {
            color: "white"
            width: parent.width
            text: plant.commonNames
            wrapMode: Text.WordWrap
         }
      }

      Button {
         id: saveButton

         anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
         }
         visible: plantCard.resultView && !!plantCard.saveFunction

         text: i18n.tr("Save this result")
         color: theme.palette.normal.positive

         onClicked: plantCard.saveFunction(plantCard.plant)
      }
   }

   function prepareImageUrl(url) {
      if (!url)
         return url;

      if (url[0] == '/')
         return 'file://' + url;

      return url;
   }
}
