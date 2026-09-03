import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Lomiri.Content 1.1
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.5 as QC
import Qt.labs.settings 1.0

import "../util"

import PlantsModel 1.0

Page {
   id: mainPage
   anchors.fill: parent
   property bool hasApiKey: false
   property string activeFilter: ""

   property var allTagsList: {
      var dummy = plantsModel.count // establish a reactive dependency on model changes
      return plantsModel.allTags()
   }

   property var visiblePlants: {
      var dummy = plantsModel.count // establish a reactive dependency on model changes
      var all = plantsModel.allPlants()

      if (!activeFilter)
         return all

      return all.filter(function (p) {
         return p.tags && p.tags.indexOf(activeFilter) !== -1
      })
   }

   header: PageHeader {
      id: header
      title: i18n.tr('Plants')

      trailingActionBar.actions: [
         Action {
            iconName: "settings"
            onTriggered: {
               mainPage.openSettings()
            }
         }
      ]
   }

   Settings {
      id: settings
      property bool disclaimerAccepted: false
   }

   Disclaimer {
      id: disclaimer
      visible: !settings.disclaimerAccepted
   }

   Rectangle {
      color: "#67676799"
      anchors.fill: parent
      visible: disclaimer.visible
      z: 100
      MouseArea {
         anchors.fill: parent
         onClicked: {}
      }
   }

   PlantsModel {
      id: plantsModel
      // identificationResult is handled by RequestPage.qml, which stays visible
      // (with its own loading feedback) for the duration of the request instead
      // of popping back here immediately.
   }

   Component.onCompleted: {
      var err = plantsModel.init()

      if (err) {
         Dialogs.showErrorDialog(
                  root, i18n.tr("Failed to init storage directory"), i18n.tr(
                     "Storage directory could not be initialized (%1).").arg(
                     err))
      } else {
         plantsModel.reload()
      }

      mainPage.hasApiKey = plantsModel.hasApiKey()
   }

   Button {
      id: analyzeButton
      anchors.top: plantsModel.count > 0 ? header.bottom : undefined
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: plantsModel.count > 0 ? parent.horizontalCenter : undefined
      anchors.centerIn: plantsModel.count > 0 ? undefined : parent
      color: plantsModel.count > 0 ? undefined : LomiriColors.green
      text: i18n.tr("New identification")
      onClicked: mainPage.startNewIdentification()
   }

   ListView {
      id: filterBar
      visible: allTagsList.length > 0
      anchors.top: analyzeButton.bottom
      anchors.topMargin: units.gu(1)
      anchors.left: parent.left
      anchors.right: parent.right
      height: visible ? units.gu(5) : 0

      orientation: ListView.Horizontal
      spacing: units.gu(1)
      leftMargin: units.gu(2)
      rightMargin: units.gu(2)
      clip: true

      model: [""].concat(allTagsList)

      delegate: TagChip {
         anchors.verticalCenter: parent.verticalCenter
         tagText: modelData === "" ? i18n.tr("All") : modelData
         selected: mainPage.activeFilter === modelData
         onClicked: function () {
            mainPage.activeFilter = modelData
         }
      }
   }

   ListView {
      id: plantList
      width: parent.width * 0.9
      anchors.top: filterBar.visible ? filterBar.bottom : analyzeButton.bottom
      anchors.bottom: footerText.top
      anchors.bottomMargin: units.gu(2)
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      clip: true
      property double rowSpacing: units.gu(1)
      spacing: rowSpacing

      model: mainPage.visiblePlants

      delegate: Component {
         PlantItem {
            imageUrl: "image://plants/" + modelData.id
            mainText: modelData.species
            subText: modelData.commonNames
            plantObject: modelData
            listMode: true

            onClicked: function (plant) {
               pageStack.push(Qt.resolvedUrl("PlantPage.qml"), {
                                 "plant": plant,
                                 "plantsModel": plantsModel
                              })
            }

            onDelete: function (plantID) {
               var dialog = Dialogs.showQuestionDialog(
                        root, i18n.tr("Delete plant?"), i18n.tr(
                           "Shall the plant '%1' be deleted? This operation can not be undone.").arg(
                           modelData.species), i18n.tr("Delete"),
                        i18n.tr("Cancel"), LomiriColors.red)

               dialog.accepted.connect(function () {
                  var err = plantsModel.deletePlant(plantID)

                  if (err) {
                     Dialogs.showErrorDialog(
                              root, i18n.tr("Deleting plant failed"), i18n.tr(
                                 "Plant could not be deleted (%1).").arg(err))
                  }
               })
            }
         }
      }
   }

   Text {
      id: emptyFilterText
      visible: mainPage.activeFilter !== "" && plantsModel.count > 0 && plantList.count === 0
      anchors.centerIn: plantList
      color: "#676767"
      text: i18n.tr("No plants with this tag")
   }

   Text {
      id: footerText
      visible: plantList.count > 0
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      text: plantList.count == 1 ? i18n.tr("1 identified plant") : i18n.tr(
                                      "%1 identified plants").arg(
                                      plantList.count)
   }

   function startNewIdentification() {
      if (!mainPage.hasApiKey) {
         var dialog = Dialogs.showErrorDialog(
                  root, i18n.tr("API Key missing"), i18n.tr(
                     "The Pl@ntNet API-Key has not been configured yet. Without this, the app will not work."))

         dialog.accepted.connect(function () {
            mainPage.openSettings()
         })
      } else {
         pageStack.push(Qt.resolvedUrl("RequestPage.qml"), {
                           "plantsModel": plantsModel
                        })
      }
   }

   function openSettings() {
      var p = pageStack.push(Qt.resolvedUrl("./SettingsPage.qml"), {
                                 "plantsModel": plantsModel
                              })

      p.apiKeyChanged.connect(function (key) {
         mainPage.hasApiKey = !!key
      })
   }
}
