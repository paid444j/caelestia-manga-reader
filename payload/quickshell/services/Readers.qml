pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string activeReader: ""

    function open(reader: string): void {
        if (["manga", "novel"].includes(reader))
            activeReader = reader;
    }

    function toggle(reader: string): void {
        activeReader = activeReader === reader ? "" : reader;
    }

    function close(): void {
        activeReader = "";
    }

    IpcHandler {
        target: "readers"

        function openManga(): void { root.open("manga"); }
        function openNovel(): void { root.open("novel"); }
        function toggleManga(): void { root.toggle("manga"); }
        function toggleNovel(): void { root.toggle("novel"); }
        function close(): void { root.close(); }
        function getActive(): string { return root.activeReader; }
    }
}
