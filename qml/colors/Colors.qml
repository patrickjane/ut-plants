pragma Singleton

import QtQuick 2.0

Item {
   property bool darkMode: false

   property color backgroundColor: darkMode ? "#121212" : "white"
   property color surfaceColor: darkMode ? "#292929" : "white"
   property color surfaceColor2:  darkMode ? "#3b3b3b" : "white"
   property color borderColor: darkMode ? "#121212" : "#e3e3e3"
   property color highlightColor: darkMode ? "#313131" : "gray"

   property color mainText: darkMode ? "#e3e3e3" : "black"
   property color detailText: darkMode ? "#acacac" : "gray"
   property color accentText: darkMode ? "#538cc6" : "#336699"
}
