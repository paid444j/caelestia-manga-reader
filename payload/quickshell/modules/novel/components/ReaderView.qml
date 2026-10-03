import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.modules.readers
import qs.services

Item {
    id: root
    signal backRequested()
    signal toggleFullscreen()
    property bool isFullscreen: false
    property real fontSize: 18
    property bool settingsVisible: false
    function reset() { textScroll.contentY = 0; }
    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.small
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Tokens.padding.medium
            Controls.IconButton {
                icon: "arrow_back"
                type: Controls.IconButton.Text
                onClicked: root.backRequested()
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    Layout.fillWidth: true
                    text: Novel.currentNovel?.title ?? ""
                    font: Tokens.font.title.small
                    elide: Text.ElideRight
                }
                StyledText {
                    Layout.fillWidth: true
                    text: Novel.currentChapter?.wordCount ? Math.round(Novel.currentChapter.wordCount / 1000 * 10) / 10 + "k words" : ""
                    font: Tokens.font.label.medium
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
            Controls.IconButton {
                icon: "text_fields"
                type: Controls.IconButton.Text
                onClicked: root.settingsVisible = !root.settingsVisible
            }
            Controls.IconButton {
                icon: root.isFullscreen ? "fullscreen_exit" : "fullscreen"
                type: Controls.IconButton.Text
                onClicked: root.toggleFullscreen()
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.large
            Layout.rightMargin: Tokens.padding.large
            visible: root.settingsVisible
            StyledText { text: "Text size"; font: Tokens.font.label.large }
            Controls.StyledSlider {
                Layout.fillWidth: true
                from: 13
                to: 28
                stepSize: 1
                value: root.fontSize
                onInteraction: v => root.fontSize = Math.round(from + v * (to - from))
            }
            StyledText { text: root.fontSize; font: Tokens.font.label.large }
        }
        Controls.StyledProgressBar {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.large
            Layout.rightMargin: Tokens.padding.large
            indeterminate: Novel.isFetchingChapter
            value: textScroll.contentHeight > textScroll.height ? Math.min(1, (textScroll.contentY + textScroll.height) / textScroll.contentHeight) : 1
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ReaderStatus {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 360)
                visible: Novel.isFetchingChapter || Novel.chapterError.length > 0 || !Novel.currentChapter
                busy: Novel.isFetchingChapter
                icon: "cloud_off"
                title: Novel.isFetchingChapter ? "Loading chapter" : "Couldn't load chapter"
                message: Novel.chapterError
                action: "Retry"
                onActionRequested: Novel.fetchChapter(Novel.currentChapterId)
            }
            Flickable {
                id: textScroll
                anchors.fill: parent
                visible: !Novel.isFetchingChapter && !Novel.chapterError && !!Novel.currentChapter
                clip: true
                contentWidth: width
                contentHeight: textColumn.implicitHeight + Tokens.padding.extraLarge * 2
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: Controls.StyledScrollBar { flickable: textScroll }
                Column {
                    id: textColumn
                    y: Tokens.padding.extraLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width - Tokens.padding.extraLarge * 2, 720)
                    spacing: root.fontSize * 1.2
                    StyledText {
                        width: parent.width
                        text: Novel.currentChapter?.title ?? ""
                        textFormat: Text.PlainText
                        font: Tokens.font.headline.small
                        wrapMode: Text.Wrap
                    }
                    Repeater {
                        model: Novel.currentChapter?.paragraphs ?? []
                        StyledText {
                            required property string modelData
                            width: textColumn.width
                            text: modelData
                            textFormat: Text.PlainText
                            font.family: Tokens.font.body.large.family
                            font.pixelSize: root.fontSize
                            wrapMode: Text.Wrap
                            lineHeight: 1.65
                        }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Tokens.padding.medium
            Controls.IconTextButton {
                text: "Previous"
                icon: "chevron_left"
                type: Controls.IconTextButton.Tonal
                disabled: !Novel.hasPrevChapter || Novel.isFetchingChapter
                onClicked: { Novel.fetchPrevChapter(); root.reset(); }
            }
            Item { Layout.fillWidth: true }
            Controls.IconTextButton {
                text: "Next chapter"
                icon: "chevron_right"
                disabled: !Novel.hasNextChapter || Novel.isFetchingChapter
                onClicked: { Novel.fetchNextChapter(); root.reset(); }
            }
        }
    }
}
