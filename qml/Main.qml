import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import Ubuntu.Content 1.1
import Ubuntu.Components.Popups 1.3

import "./util"
import "./pages"

MainView {
   id: root
   objectName: 'mainView'
   applicationName: 'plants.s710'
   automaticOrientation: false
   anchorToKeyboard: true

   width: units.gu(45)
   height: units.gu(75)

   Text { id: text; font.pointSize: units.gu(1) }

   PageStack {
      id: pageStack
      anchors {
         fill: parent
      }

      Component.onCompleted: {
         push(mainPage)
      }


      MainPage {
         id: mainPage
         visible: false
      }
   }
}
