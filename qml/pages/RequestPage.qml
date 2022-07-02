import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.1
import Ubuntu.Content 1.1
import QtGraphicalEffects 1.12

import "../util"

import PlantsModel 1.0

Page {
   property var plantsModel: null

   header: PageHeader {
      id: header
      title: i18n.tr('New identification')
   }

   function importImages(urls) {
      console.log("Import URLS:", JSON.stringify(urls));

      urls.forEach(function(fileUrl) {
         if (imageModel.count < 6)
            imageModel.insert(imageModel.count-1, {type: 'image', url: fileUrl + '', organ: PlantUtils.organs[1].name });
      });
   }

   Text {
      id: titleText

      anchors {
         top: header.bottom
         topMargin: units.gu(2)
         horizontalCenter: parent.horizontalCenter
      }

      width: parent.width * 0.9

      text: i18n.tr('Add up to 5 images for identification. The images must be of the same plant. The more images are provided, the better the identification result will be.')
         + '\n\n'
         + i18n.tr('Pl@ntNet recommends images with the smaller side larger than 600px and smaller than 2000px. Ideally a square image zoomed on the organ around 1280x1280px.')

      color: Theme.palette.normal.baseText

      wrapMode: Text.WordWrap
   }

   ListModel {
      id: imageModel

      ListElement {
         type: "placeholder"
         url: ''
         organ: ''
      }
   }

   Component {
      id: selectorDelegate
      OptionSelectorDelegate { text: title }
   }

   Button {
      id: analyzeButton

      anchors {
         bottom: parent.bottom
         bottomMargin: units.gu(3)
         horizontalCenter: parent.horizontalCenter
      }

      text: i18n.tr("Identify")
      color: theme.palette.normal.positive

      enabled: imageModel.count >= 5
      onClicked: {
         var request = [];

         for (const i in imageModel) {
            const entry = imageModel.get(i);

            if (entry.type == "placeholder")
               continue;

            request.push({
               url: entry.url.replace("file://", ""),
               organ: entry.organ,
            });
         }

         plantsModel.identifyPlant(request);
         pageStack.pop();
         mainPage.loadingScreenShown = true;
      }
   }

   ListView {
      id: imageList
      property double rowSpacing: units.gu(1)

      model: imageModel

      anchors {
         topMargin: units.gu(2)
         top: titleText.bottom
         bottom: analyzeButton.top
         bottomMargin: units.gu(2)
         horizontalCenter: parent.horizontalCenter
      }

      width: parent.width * 0.9
      spacing: rowSpacing
      clip: true

      delegate: Component {
         PlantItem {
            imageUrl: url || ''
            mainText: organ && PlantUtils.toTitle(organ) || ''
            listMode: false
            placeholder: type == "placeholder"
            visible: !placeholder || imageModel.count < 6 // FIXME: Visible if not a placeholder OR less then 6 images. Is it a logic error?

            onClicked: function() {
               // FIXME: You're returning it it isn't a placeholder. Are you only adding placeholders?
               if (type != "placeholder")
                  return;

               addNewImage();
            }

            onEdit: function() {
               var dialog = Dialogs.showPickerDialog(root);

               dialog.accepted.connect(function() {
                  mainText = PlantUtils.toTitle(dialog.selection);
               });
            }

            onDelete: function() {
               imageModel.remove(index, 1);
            }
         }
      }
   }

   function addNewImage() {
      var importPage = pageStack.push(Qt.resolvedUrl("ImportPage.qml"), {});
      importPage.imported.connect(importImages);
   }
}
