import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Content 1.1
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.5 as QC
import Qt.labs.settings 1.0

import "../notify"
import "../util"
import "../colors"

import PlantsModel 1.0

Page {
   id: mainPage
   anchors.fill: parent
   property bool loadingScreenShown: false

   header: PageHeader {
      id: header
      title: i18n.tr('Plants')

      trailingActionBar.actions: [
         Action {
            iconName: "settings"
            onTriggered: {
               mainPage.openSettings();
            }
         }
      ]
   }

   Settings {
      id: settings
      property string apiKey
   }

   LoadingScreen {
      visible: mainPage.loadingScreenShown
   }

   PlantsModel {
      id: plantsModel

      onIdentificationResult: {
         mainPage.loadingScreenShown = false

         if (error) {
            Dialogs.showErrorDialog(root,
                                 i18n.tr("Identification failed"),
                                 i18n.tr("Failed to send identification request to Pl@ntNet (%1).").arg(error))
            return
         }

         pageStack.push(Qt.resolvedUrl("ResultsPage.qml"), { resultsData: result, plantsModel: plantsModel })
      }
   }

   Component.onCompleted: {
      var err = plantsModel.init();

      if (err != "") {
         Dialogs.showErrorDialog(root,
                                 i18n.tr("Failed to init storage directory"),
                                 i18n.tr("Storage directory could not be initialized (%1).").arg(err))
      } else {
         plantsModel.reload();
      }
   }

   Rectangle {
      id: placeholder
      radius: units.gu(4)
      border.width: 2
      border.color: "#cdcdcd"
      visible: !plantsModel.count

      anchors.centerIn: parent
      width: parent.width * 0.7
      height: units.gu(8)

      Column {
         anchors.centerIn: parent
         spacing: units.gu(2)

         Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("No plants identified yet")
         }
      }
   }

   Button {
      id: analyzeButton
      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      text: i18n.tr("New identification")
      onClicked: {
         if (!settings.apiKey) {
            var dialog = Dialogs.showErrorDialog(root,
                                                i18n.tr("API Key missing"),
                                                i18n.tr("The Pl@ntNet API-Key has not been configured yet. Without this, the app will not work."))

            dialog.accepted.connect(function() {
               mainPage.openSettings();
            })
         } else {
            pageStack.push(Qt.resolvedUrl("RequestPage.qml"), { plantsModel: plantsModel })
         }
      }
   }

   ListView {
      id: plantList
      width: parent.width * 0.9
      anchors.top: analyzeButton.bottom
      anchors.bottom: footerText.top
      anchors.bottomMargin: units.gu(2)
      anchors.topMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      clip: true
      property double rowSpacing: units.gu(1)
      spacing: rowSpacing

      model: plantsModel

      delegate: Component {
         PlantItem {
            imageUrl: "image://plants/" + plant.id
            mainText: plant.species
            plantObject: plant
            listMode: true

            onClicked: function(plant) {
               pageStack.push(Qt.resolvedUrl("PlantPage.qml"), { plant: plant })
            }

            onDelete: function(plantID) {
               var dialog = Dialogs.showQuestionDialog(root,
                              i18n.tr("Delete plant?"),
                              i18n.tr("Shall the plant '%1' be deleted? This operation can not be undone.").arg(plant.species),
                              i18n.tr("Delete"),
                              i18n.tr("Cancel"),
                              UbuntuColors.red)

               dialog.accepted.connect(function() {
                  var err = plantsModel.deletePlant(plantID)

                  if (err != "") {
                     Dialogs.showErrorDialog(root,
                        i18n.tr("Deleting plant failed"),
                        i18n.tr("Plant could not be deleted (%1).").arg(err))
                  }
               })
            }
         }
      }
   }

   Text {
      id: footerText
      visible: plantList.count > 0
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(2)
      anchors.horizontalCenter: parent.horizontalCenter
      text: plantList.count == 1
         ? i18n.tr("1 identified plant")
         : i18n.tr("%1 identified plants").arg(plantList.count)
   }

   function openSettings() {
      var p = pageStack.push(Qt.resolvedUrl("./SettingsPage.qml"))

      p.apiKeyChanged.connect(function(key) {
         settings.apiKey = key
         plantsModel.setApiKey(key);
      })
   }
}
