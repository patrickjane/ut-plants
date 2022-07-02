import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Themes 1.3
import QtQuick 2.7
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.Layouts 1.0

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
      anchors {
         top: header.bottom
         left: parent.left
         right: parent.right
         bottom: parent.bottom
      }

      contentWidth: parent.width
      contentHeight: childrenRect.height

      clip: true

      Column {
         anchors {
            left: parent.left
            right: parent.right
         }

         ListItem {
            height: l1.height + (divider.visible ? divider.height : 0)

            ListItemLayout {
               id: l1

               title.text: i18n.tr("Pl@ntNet API key")
               title.font.bold: true
               title.color: Theme.palette.normal.baseText
            }
         }

         ListItem {
            anchors {
               left: parent.left
               right: parent.right
            }
            height: l2.height + (divider.visible ? divider.height : 0)

            SlotsLayout {
               id: l2
               mainSlot: Text {
                  anchors.verticalCenter: parent.verticalCenter

                  text: i18n.tr("In order to use the Pl@ntNet plant identification service, it is necessary to register at their website as developer and obtain an API-Key. This key needs to be configured within this app.\n\nPlease visit https://my.plantnet.org/signup and create an account. Afterwards visit https://my.plantnet.org/account and click the eye-symbol at the very top (\"my API key\") to show the API-Key. Copy this key and paste it into the below text input field.")

                  color: Theme.palette.normal.baseText
                  wrapMode: Text.WordWrap
               }
            }
         }

         ListItem {
            anchors {
               left: parent.left
               right: parent.right
            }
            height: l4.height + (divider.visible ? divider.height : 0)

            SlotsLayout {
               id: l4

               mainSlot: Column {
                  spacing: units.gu(1)

                  Text {
                     text: i18n.tr("API-Key:")
                     color: Theme.palette.normal.baseText
                  }

                  RowLayout {
                     anchors {
                        left: parent.left
                        right: parent.right
                     }
                     spacing: units.gu(2)

                     TextField {
                        id: apiKeyInput
                        Layout.fillWidth: true

                        text: settings.apiKey
                        placeholderText: i18n.tr("Enter API-Key")
                     }

                     Button {
                        id: saveButton

                        text: i18n.tr("Save")
                        color: theme.palette.normal.positive

                        enabled: settings.apiKey != apiKeyInput.text
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
      }
   }
}
