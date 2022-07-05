pragma Singleton

import QtQuick 2.4
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Pickers 1.3
import QtQuick.Controls 2.5 as QC

import "../util"

Item {
   Component {
      id: questionDialogComponent

      Dialog {
         id: questionDialog
         property string acceptButtonTitle: i18n.tr("Okay")
         property string cancelButtonTitle: i18n.tr("Cancel")
         property color acceptButtonColor: UbuntuColors.green

         signal accepted
         signal rejected

         Button {
            text: acceptButtonTitle
            color: acceptButtonColor
            onClicked: {
               questionDialog.accepted()
               PopupUtils.close(questionDialog)
            }
         }
         Button {
            text: cancelButtonTitle
            onClicked: {
               questionDialog.rejected()
               PopupUtils.close(questionDialog)
            }
         }
      }
   }

   Component {
      id: errorDialogComponent

      Dialog {
         id: errorDialog
         signal accepted

         Button {
            text: i18n.tr("Close")
            onClicked: {
               errorDialog.accepted()
               PopupUtils.close(errorDialog)
            }
         }
      }
   }

   Component {
      id: pickerDialogComponent

      Dialog {
         id: pickerDialog
         property string selection: PlantUtils.organs[0].name
         property color acceptButtonColor: UbuntuColors.green

         signal accepted

         Text {
            text: i18n.tr("Select plant part")
         }

         Repeater {
            model: PlantUtils.organs.length

            QC.RadioButton {
               text: PlantUtils.organs[index].title
               onClicked: selection = PlantUtils.organs[index].name
            }
         }

         Button {
            text: i18n.tr("Okay")
            color: acceptButtonColor
            onClicked: {
               pickerDialog.accepted()
               PopupUtils.close(pickerDialog)
            }
         }
      }
   }

   Component {
      id: storageErrorDialogComponent

      Dialog {
         id: storageErrorDialog
         title: i18n.tr("Failed to init storage directory")
         text: i18n.tr("Storage directory could not be initialized (%1).").arg(
                  errorString)

         property string errorString

         Button {
            text: i18n.tr("Close")
            onClicked: {
               PopupUtils.close(storageErrorDialog)
            }
         }
      }
   }

   function showQuestionDialog(parent, title, text, acceptButtonTitle, cancelButtonTitle, acceptButtonColor) {
      return PopupUtils.open(questionDialogComponent, parent, {
                                "title": title,
                                "text": text,
                                "acceptButtonTitle": acceptButtonTitle,
                                "cancelButtonTitle": cancelButtonTitle,
                                "acceptButtonColor": acceptButtonColor
                             })
   }

   function showErrorDialog(parent, title, text) {
      return PopupUtils.open(errorDialogComponent, parent, {
                                "title": title,
                                "text": text
                             })
   }

   function showPickerDialog(parent) {
      return PopupUtils.open(pickerDialogComponent, parent, {})
   }
}
