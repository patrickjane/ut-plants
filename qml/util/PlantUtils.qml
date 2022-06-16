pragma Singleton

import QtQuick 2.4
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Pickers 1.3

Item {
   property var organs: ([
      {name: "auto", title: i18n.tr("Auto")},
      {name: "leaf", title: i18n.tr("Leaf")},
      {name: "flower", title: i18n.tr("Flower")},
      {name: "fruit", title: i18n.tr("Fruit")},
      {name: "bark", title: i18n.tr("Bark")}
   ])

   function toTitle(name) {
      for (var i = 0; i < organs.length; i++) {
         if (organs[i].name == name)
            return organs[i].title
      }

      return ""
   }
}