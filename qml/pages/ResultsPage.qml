import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Lomiri.Content 1.1
import QtQuick.Controls 2.5 as QC

import "../util"

import PlantsModel 1.0

Page {
   id: mainPage
   anchors.fill: parent

   property var plantsModel: nil
   property var resultsData: []

   header: PageHeader {
      id: header
      title: i18n.tr('Identification results')
   }

   Component.onCompleted: {
      resultsData.forEach(function (res) {
         resultsModel.append(res)
      })
   }

   ListModel {
      id: resultsModel
   }

   QC.PageIndicator {
      id: pageIndicator
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(2)

      currentIndex: resultList.currentIndex
      count: resultList.count
   }

   ListView {
      id: resultList
      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: pageIndicator.top
      anchors.bottomMargin: units.gu(2)

      clip: true
      orientation: ListView.Horizontal
      snapMode: ListView.SnapToItem
      highlightRangeMode: ListView.StrictlyEnforceRange

      property double elementSpacing: units.gu(2)

      model: resultsModel

      delegate: Component {
         PlantCard {
            width: resultList.width
            height: resultList.height

            plant: resultsData[index]
            resultView: true

            saveFunction: function (plant) {
               var err = plantsModel.savePlant(plant)

               if (!err) {
                  pageStack.pop()
               } else {
                  Dialogs.showErrorDialog(
                           root, i18n.tr("Saving result failed"),
                           i18n.tr("Result could not be saved (%1).").arg(err))
               }
            }
         }
      }
   }
}
