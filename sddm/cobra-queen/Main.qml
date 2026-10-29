// ── COBRA QUEEN · SDDM greeter (Qt6) ─────────────
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: base

    readonly property color base:     "#07090b"
    readonly property color surface2: "#121b20"
    readonly property color edge:     "#1f3638"
    readonly property color venom:    "#3bf0b6"
    readonly property color scale:    "#17a68c"
    readonly property color toxic:    "#8a7bff"
    readonly property color hood:     "#ff2d63"
    readonly property color fang:     "#ff4d6d"
    readonly property color txt:      "#e6f2ee"
    readonly property color muted:    "#86a09a"
    readonly property color ink:      "#03140f"
    readonly property string mono:    "JetBrainsMono Nerd Font"
    readonly property string display: "Orbitron"

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string userName: userModel.lastUser
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    function doLogin() {
        errorText.text = ""
        sddm.login(root.userName, password.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Wrong password. The queen is not amused."
            password.text = ""
            password.forceActiveFocus()
            shake.start()
        }
    }

    Component.onCompleted: password.forceActiveFocus()

    // ── Wallpaper ────────────────────────────────
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 60
        spacing: 8
        Text {
            text: config.tagline
            color: "#cce6f2ee"
            font.family: root.display
            font.pixelSize: 12
            font.letterSpacing: 5
        }
        Rectangle { anchors.right: parent.right; width: 120; height: 2; color: root.hood }
    }

    // ── Glass panel ──────────────────────────────
    Rectangle {
        id: panel
        width: Math.min(640, root.width * 0.42)
        height: parent.height
        color: "#d907090b"

        Rectangle {
            anchors.right: parent.right
            width: 1
            height: parent.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#803bf0b6" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 72
            anchors.leftMargin: 88
            anchors.rightMargin: 88

            // Brand
            Row {
                spacing: 14
                Rectangle {
                    width: 44; height: 44; radius: 12
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: root.venom }
                        GradientStop { position: 1; color: root.scale }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: root.mono
                        font.pixelSize: 20
                        color: root.ink
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: "COBRA QUEEN"
                        font.family: root.display
                        font.weight: Font.ExtraBold
                        font.pixelSize: 18
                        font.letterSpacing: 3
                        color: root.txt
                    }
                    Text { text: "arch · hyprland"; font.family: root.mono; font.pixelSize: 11; color: root.muted }
                }
            }

            // Form
            Column {
                id: form
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: 28

                Column {
                    spacing: 8
                    Text {
                        text: "Welcome back."
                        font.family: root.display
                        font.bold: true
                        font.pixelSize: 40
                        color: root.txt
                    }
                    Text {
                        text: "Shed the day. Sign in to " + sddm.hostName + "."
                        font.family: root.mono
                        font.pixelSize: 14
                        color: root.muted
                    }
                }

                // Users
                Row {
                    width: parent.width
                    spacing: 12
                    Repeater {
                        id: users
                        model: userModel
                        delegate: Rectangle {
                            readonly property bool sel: index === root.userIndex
                            width: (form.width - 12 * (users.count - 1)) / Math.max(users.count, 1)
                            height: 72
                            radius: 14
                            color: sel ? "#143bf0b6" : "#99121b20"
                            border.color: sel ? "#993bf0b6" : root.edge
                            border.width: 1

                            Item {
                                id: avatar
                                width: 40; height: 40
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    id: face
                                    anchors.fill: parent
                                    source: model.icon
                                    fillMode: Image.PreserveAspectCrop
                                    visible: false
                                    layer.enabled: true
                                }
                                Rectangle {
                                    id: faceMask
                                    anchors.fill: parent
                                    radius: width / 2
                                    visible: false
                                    layer.enabled: true
                                }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: face
                                    maskEnabled: true
                                    maskSource: faceMask
                                }
                            }

                            Column {
                                anchors.left: avatar.right
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3
                                Text {
                                    text: model.realName || model.name
                                    font.family: root.mono
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: sel ? root.txt : root.muted
                                }
                                Text { text: model.name; font.family: root.mono; font.pixelSize: 11; color: root.muted }
                            }

                            Text {
                                visible: sel
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: ""
                                font.family: root.mono
                                font.pixelSize: 18
                                color: root.venom
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.userIndex = index
                                    root.userName = model.name
                                    password.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                // Password
                Column {
                    width: parent.width
                    spacing: 8
                    Text { text: "PASSWORD"; font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 2; color: root.muted }
                    Rectangle {
                        id: pwBox
                        width: parent.width
                        height: 52
                        radius: 12
                        color: "#cc121b20"
                        border.color: password.activeFocus ? root.venom : root.edge
                        border.width: password.activeFocus ? 1.5 : 1
                        transform: Translate { id: shakeT }

                        SequentialAnimation {
                            id: shake
                            loops: 2
                            NumberAnimation { target: shakeT; property: "x"; to: -10; duration: 50 }
                            NumberAnimation { target: shakeT; property: "x"; to: 10;  duration: 80 }
                            NumberAnimation { target: shakeT; property: "x"; to: 0;   duration: 50 }
                        }

                        Text {
                            id: keyIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            font.family: root.mono
                            font.pixelSize: 16
                            color: password.activeFocus ? root.venom : root.muted
                        }
                        TextField {
                            id: password
                            anchors.left: keyIcon.right
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            echoMode: TextInput.Password
                            passwordCharacter: "●"
                            placeholderText: "enter password"
                            placeholderTextColor: root.muted
                            color: root.txt
                            selectionColor: root.venom
                            selectedTextColor: root.ink
                            font.family: root.mono
                            font.pixelSize: 15
                            background: null
                            onAccepted: root.doLogin()
                        }
                    }
                    Text {
                        id: errorText
                        text: keyboard.capsLock ? "Caps Lock is on" : ""
                        font.family: root.mono
                        font.pixelSize: 12
                        color: root.fang
                    }
                }

                // Session
                Column {
                    width: parent.width
                    spacing: 8
                    Text { text: "SESSION"; font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 2; color: root.muted }
                    ComboBox {
                        id: session
                        width: parent.width
                        height: 52
                        model: sessionModel
                        textRole: "name"
                        currentIndex: root.sessionIndex
                        onActivated: root.sessionIndex = currentIndex

                        background: Rectangle { radius: 12; color: "#cc121b20"; border.color: root.edge; border.width: 1 }
                        contentItem: Text {
                            leftPadding: 44
                            text: "    " + session.displayText
                            color: root.txt
                            font.family: root.mono
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                        }
                        indicator: Text {
                            x: session.width - width - 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            font.family: root.mono
                            font.pixelSize: 12
                            color: root.muted
                        }
                        delegate: ItemDelegate {
                            width: session.width
                            highlighted: session.highlightedIndex === index
                            contentItem: Text {
                                text: model.name
                                color: root.txt
                                font.family: root.mono
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { radius: 8; color: highlighted ? "#1a3bf0b6" : "transparent" }
                        }
                        popup: Popup {
                            y: session.height + 4
                            width: session.width
                            padding: 4
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: session.popup.visible ? session.delegateModel : null
                                currentIndex: session.highlightedIndex
                            }
                            background: Rectangle { radius: 10; color: root.surface2; border.color: root.edge }
                        }
                    }
                }

                // Sign in
                Rectangle {
                    width: parent.width
                    height: 54
                    radius: 12
                    opacity: signIn.containsMouse ? 0.9 : 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: root.venom }
                        GradientStop { position: 1; color: root.scale }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "SIGN IN  "
                        font.family: root.display
                        font.weight: Font.ExtraBold
                        font.pixelSize: 14
                        font.letterSpacing: 3
                        color: root.ink
                    }
                    MouseArea {
                        id: signIn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.doLogin()
                    }
                }
            }

            // Footer
            Row {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                spacing: 10
                Repeater {
                    model: [
                        { icon: "", tint: "#ff4d6d", act: "off",     ok: sddm.canPowerOff },
                        { icon: "", tint: "#86a09a", act: "reboot",  ok: sddm.canReboot },
                        { icon: "", tint: "#86a09a", act: "suspend", ok: sddm.canSuspend }
                    ]
                    delegate: Rectangle {
                        visible: modelData.ok
                        width: 40; height: 40; radius: 10
                        color: btn.containsMouse ? "#1a3bf0b6" : "#cc121b20"
                        border.color: root.edge
                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: root.mono
                            font.pixelSize: 16
                            color: modelData.tint
                        }
                        MouseArea {
                            id: btn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.act === "off") sddm.powerOff()
                                else if (modelData.act === "reboot") sddm.reboot()
                                else sddm.suspend()
                            }
                        }
                    }
                }
            }

            Column {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 4
                Text {
                    id: clock
                    anchors.right: parent.right
                    font.family: root.display
                    font.bold: true
                    font.pixelSize: 20
                    color: root.venom
                }
                Text {
                    id: date
                    anchors.right: parent.right
                    font.family: root.mono
                    font.pixelSize: 11
                    font.letterSpacing: 1
                    color: root.muted
                }
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: {
                        const now = new Date()
                        clock.text = Qt.formatTime(now, "hh:mm")
                        const kb = keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : ""
                        date.text = Qt.formatDate(now, "ddd dd MMM").toUpperCase() + (kb ? " · " + kb : "")
                    }
                }
            }
        }
    }
}
