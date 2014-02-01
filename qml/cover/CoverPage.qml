/*
    TaskList - A small but mighty program to manage your daily tasks.
    Copyright (C) 2014 Thomas Amler
    Contact: Thomas Amler <armadillo@penguinfriends.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.1
import Sailfish.Silica 1.0
import "../localdb.js" as DB

CoverBackground {
    id: taskPage

    BackgroundItem {
        anchors.fill: parent

        Image {
            id: coverBgImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "../images/coverbg.png"
            opacity: 0.2
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }
    }

    // helper function to add tasks to the list
    function appendTask(id, task, status) {
        taskListModel.append({"taskid": id, "task": task, "taskstatus": status})
    }

    // helper function to wipe the tasklist element
    function wipeTaskList() {
        taskListModel.clear()
    }

    function reloadTaskList() {
        var listorder


        switch(taskListWindow.coverListOrder) {
        case 0:
            listorder = ", LastUpdate DESC"
            break
        case 1:
            listorder = ", Task ASC"
            break
        case 2:
            listorder = ", Task DESC"
            break
        }

        wipeTaskList()
        switch(taskListWindow.coverListSelection) {
        case 0:
            DB.readTasks(taskListWindow.defaultlist, 1, listorder)
            break
        case 1:
            DB.readTasks(taskListWindow.listid, 1, listorder)
            break
        case 2:
            DB.readTasks(taskListWindow.coverListChoose, 1, listorder)
            break
        }
    }

    // read all tasks after start
    Component.onCompleted: {
        reloadTaskList()
    }

    onStatusChanged: {
        reloadTaskList()
    }

    ListModel {
        id: taskListModel
    }

    ListView {
        anchors.fill: parent
        Label {
            id: coverHeader
            text: {
                switch(taskListWindow.coverListSelection) {
                case 0:
                    DB.getListProperty(taskListWindow.defaultlist, "ListName")
                    break
                case 1:
                    DB.getListProperty(taskListWindow.listid, "ListName")
                    break
                case 2:
                    DB.getListProperty(taskListWindow.coverListChoose, "ListName")
                    break
                }
            }
            width: parent.width
            anchors.top: parent.top
            horizontalAlignment: Text.Center
        }

        ListView {
            id: taskList
            anchors.top: coverHeader.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            model: taskListModel

            // show playholder if there are no tasks available
            ViewPlaceholder {
                enabled: taskList.count === 0
                text: qsTr("no tasks available")
            }

            delegate: Row {
                id: taskListItem
                width: parent.width

                BackgroundItem {
                    id: taskContainerItem
                    width: parent.width
                    height: 32

                    Label {
                        id: taskLabel
                        x: Theme.paddingSmall
                        text: task
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }
        }

        OpacityRampEffect {
            slope: 1.5
            offset: 0.35
            sourceItem: taskList
        }

        CoverActionList {
            id: coverAction

            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: {
                    taskListWindow.coverAddTask = true
                    taskListWindow.activate()
                    pageStack.replace(Qt.resolvedUrl("../pages/TaskPage.qml"))
                }
            }

            // not needed atm
            /*CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: {
                taskListWindow.activate()
            }*/
        }
    }
}


