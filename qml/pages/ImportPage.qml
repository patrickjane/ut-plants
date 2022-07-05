import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Page {
   id: picker
   property var activeTransfer
   property var url

   signal imported(var urls)

   header: PageHeader {
      title: i18n.tr("Load image")
   }

   ContentPeerPicker {
      anchors.fill: parent
      anchors.topMargin: picker.header.height
      showTitle: false
      contentType: ContentType.Pictures
      handler: ContentHandler.Source

      onPeerSelected: {
         peer.selectionType = ContentTransfer.Multiple
         picker.activeTransfer = peer.request()

         picker.activeTransfer.stateChanged.connect(function () {
            if (!picker.activeTransfer)
               return

            if (picker.activeTransfer.state === ContentTransfer.Charged) {
               var urls = Object.keys(picker.activeTransfer.items).map(
                        function (k) {
                           return picker.activeTransfer.items[k].url
                        })
               picker.imported(urls)
               picker.activeTransfer = null
               pageStack.pop()
            }
         })
      }

      onCancelPressed: {
         pageStack.pop()
      }
   }

   ContentTransferHint {
      id: transferHint
      anchors.fill: parent
      activeTransfer: picker.activeTransfer
   }

   Component {
      id: resultComponent
      ContentItem {}
   }
}
