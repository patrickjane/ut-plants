import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Themes 1.3
import QtQuick 2.7
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Page {
   id: settingsPage
   anchors.fill: parent
   signal updateIntervalChanged(var interval, var enabled)
   signal apiKeyChanged(var key)

   Settings {
      id: settings
      property string apiKey
   }

   header: PageHeader {
      id: header
      title: i18n.tr("Settings")
   }

   Flickable {
      anchors.top: header.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom

      contentWidth: parent.width
      contentHeight: childrenRect.height

      clip: true
      flickableDirection: Flickable.AutoFlickIfNeeded

      Column {
         anchors.left: parent.left
         anchors.right: parent.right

         ListItem {
            height: l1.height
            divider.visible: false

            ListItemLayout {
               id: l1
               title.text: i18n.tr("Pl@ntNet API key")
               title.font.bold: true
               title.color: Theme.palette.normal.baseText
            }
         }

         ListItem {
            anchors.left: parent.left
            anchors.right: parent.right
            height: l4.height
            divider.visible: false

            SlotsLayout {
               id: l4
               mainSlot: Column {
                  spacing: units.gu(1)
                  Text {
                     text: i18n.tr("API-Key:")
                     color: Theme.palette.normal.baseText
                  }

                  Row {
                     anchors.left: parent.left
                     anchors.right: parent.right
                     anchors.rightMargin: units.gu(1)
                     spacing: units.gu(1)

                     TextField {
                        id: apiKeyInput
                        placeholderText: i18n.tr("Enter API-Key")
                        width: parent.width - units.gu(2) - saveButton.width
                        text: settings.apiKey
                     }

                     Button {
                        id: saveButton
                        enabled: settings.apiKey !== apiKeyInput.text
                        text: i18n.tr("Save")
                        onClicked: {
                           settings.apiKey = apiKeyInput.text
                           emit: apiKeyChanged(apiKeyInput.text)
                           pageStack.pop()
                        }
                     }
                  }
               }
            }
         }

         ListItem {
            anchors.left: parent.left
            anchors.right: parent.right
            height: l2.height
            divider.visible: false

            SlotsLayout {
               id: l2
               mainSlot: Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: i18n.tr(
                           "In order to use the Pl@ntNet plant identification service, it is necessary to register at their website as developer and obtain an API-Key. This key needs to be configured within this app.\n\nPlease visit https://my.plantnet.org/signup and create an developer account. Afterwards visit https://my.plantnet.org/account and click the eye-symbol at the very top (\"my API key\") to show the API-Key. Copy this key and paste it into the text input field above.")
                  color: Theme.palette.normal.baseText
                  wrapMode: Text.WordWrap
               }
            }
         }
      }
   }
}
