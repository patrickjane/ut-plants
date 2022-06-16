pragma Singleton

import QtQuick 2.0

Item {
   id: notifications
   property var queue: []
   property var activeNotification
   property var listener

   function register(notification) {
      listener = notification
   }

   function deregister() {
      listener = undefined
   }

   function info(title, text) {
      queue.push({ type: "info", title, text })

      if (!activeNotification)
         nextNotification()
   }

   function warning(title, text) {
      queue.push({ type: "warning", title, text })

      if (!activeNotification)
         nextNotification()
   }

   function error(title, text) {
      queue.push({ type: "error", title, text })

      if (!activeNotification)
         nextNotification()
   }

   function dismiss() {
      timerAutoDismiss.stop()
      activeNotification = undefined

      if (listener)
         listener.onNotification(activeNotification)

      timerNextNotification.restart()
   }

   function skipAutoDismiss() {
      timerAutoDismiss.stop()
   }

   function nextNotification() {
      activeNotification = queue.shift()

      if (listener)
         listener.onNotification(activeNotification)

      if (activeNotification && activeNotification.type === "info" || activeNotification && activeNotification.type === "warning")
         timerAutoDismiss.start()
   }

   Timer {
      id: timerNextNotification
      interval: 700
      repeat: false
      running: false

      onTriggered: nextNotification()
   }

   Timer {
      id: timerAutoDismiss
      interval: 5000
      repeat: false
      running: false

      onTriggered: dismiss()
   }
}
