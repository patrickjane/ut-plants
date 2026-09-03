import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Lomiri.Content 1.1
import QtGraphicalEffects 1.12

import "../util"

Page {
   id: plantPage
   anchors.fill: parent

   property var plant: nil
   property var plantsModel: null
   property var currentTags: plant && plant.tags ? plant.tags : []

   header: PageHeader {
      id: header
      title: i18n.tr('Plant details')
   }

   PlantCard {
      id: plantCard
      plant: plantPage.plant

      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.bottom: tagsSection.top
      anchors.bottomMargin: units.gu(2)
      width: parent.width
   }

   Column {
      id: tagsSection
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(4)
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: units.gu(2)
      anchors.rightMargin: units.gu(2)
      spacing: units.gu(1)

      Text {
         text: i18n.tr("Tags")
         font.bold: true
         color: Theme.palette.normal.baseText
      }

      Flow {
         width: parent.width
         spacing: units.gu(1)
         visible: currentTagsRepeater.count > 0

         Repeater {
            id: currentTagsRepeater
            model: plantPage.currentTags

            TagChip {
               tagText: modelData
               removable: true
               onRemove: function () {
                  plantPage.removeTag(modelData)
               }
            }
         }
      }

      Row {
         width: parent.width
         spacing: units.gu(1)

         TextField {
            id: newTagInput
            width: parent.width - addTagButton.width - parent.spacing
            placeholderText: i18n.tr("Add a tag...")
            onAccepted: {
               plantPage.addTag(text)
               text = ""
            }
         }

         Button {
            id: addTagButton
            text: i18n.tr("Add")
            enabled: newTagInput.text.trim().length > 0
            onClicked: {
               plantPage.addTag(newTagInput.text)
               newTagInput.text = ""
            }
         }
      }

      Flow {
         width: parent.width
         spacing: units.gu(1)
         visible: suggestionsRepeater.count > 0

         Repeater {
            id: suggestionsRepeater
            model: plantPage.suggestedTags()

            TagChip {
               tagText: modelData
               onClicked: function () {
                  plantPage.addTag(modelData)
               }
            }
         }
      }
   }

   function suggestedTags() {
      if (!plantsModel)
         return []

      return plantsModel.allTags().filter(function (tag) {
         return currentTags.indexOf(tag) === -1
      })
   }

   function addTag(tag) {
      tag = tag.trim()

      if (!tag || !plant || currentTags.indexOf(tag) !== -1)
         return

      var tags = currentTags.slice()
      tags.push(tag)

      var err = plantsModel.setPlantTags(plant.id, tags)

      if (!err)
         currentTags = tags
      else
         Dialogs.showErrorDialog(root, i18n.tr("Failed to update tags"), err)
   }

   function removeTag(tag) {
      var tags = currentTags.filter(function (t) {
         return t !== tag
      })

      var err = plantsModel.setPlantTags(plant.id, tags)

      if (!err)
         currentTags = tags
      else
         Dialogs.showErrorDialog(root, i18n.tr("Failed to update tags"), err)
   }
}
