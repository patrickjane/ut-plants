import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Content 1.1
import QtGraphicalEffects 1.12

import "../notify"
import "../util"
import "../colors"

Page {
   id: plantPage
   anchors.fill: parent

   property var plant: nil

   header: PageHeader {
      id: header
      title: i18n.tr('Plant details')
   }

   PlantCard {
      id: plantCard
      plant: plantPage.plant

      anchors.top: header.bottom
      anchors.topMargin: units.gu(2)
      anchors.bottom: parent.bottom
      anchors.bottomMargin: units.gu(2)
      width: parent.width
   }
}