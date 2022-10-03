import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import Ubuntu.Content 1.1
import Ubuntu.Components.Popups 1.3
import Qt.labs.settings 1.0
import QtSystemInfo 5.0

import "./util"
import "./pages"

MainView {
   id: root
   objectName: 'mainView'
   applicationName: 'plants.s710'
   automaticOrientation: false

   width: units.gu(45)
   height: units.gu(75)

   Settings {
      id: settings
      property bool keepDisplayOn: false
   }

   ScreenSaver {
      id: screen_saver
      screenSaverEnabled: !settings.keepDisplayOn
   }

   PageStack {
      id: pageStack
      anchors.fill: parent

      Component.onCompleted: {
         push(mainPage)
      }

      MainPage {
         id: mainPage
         visible: false
      }
   }
}
