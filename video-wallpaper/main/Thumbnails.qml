
import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Services.UI

Item {
    id: root
    required property var pluginApi


    /***************************
    * PROPERTIES
    ***************************/
    required property string currentWallpaper 
    required property bool thumbCacheReady
    required property FolderListModel folderModel

    readonly property string thumbCacheFolder: ImageCacheService.wpThumbDir + "video-wallpaper"
    property int _thumbGenIndex: 0
    property list<string> thumbCacheFolderFiles: []


    /***************************
    * FUNCTIONS
    ***************************/
    function clearThumbCacheReady() {
        if(pluginApi != null && thumbCacheReady) {
            pluginApi.pluginSettings.thumbCacheReady = false;
            pluginApi.saveSettings();
        }
    }

    function setThumbCacheReady() {
        if(pluginApi != null && !thumbCacheReady) {
            pluginApi.pluginSettings.thumbCacheReady = true;
            pluginApi.saveSettings();
        }
    }


    function getThumbPath(videoPath: string): string {
        const file = videoPath.split('/').pop();

        return `${thumbCacheFolder}/${file}.bmp`
    }


    function startColorGen() {
        thumbColorGenTimer.start();
    }


    function thumbGeneration() {
        if(pluginApi == null) return;

        // Reset the state of thumbCacheReady
        clearThumbCacheReady();

        while(root._thumbGenIndex < folderModel.count) {
            const videoPath = folderModel.get(root._thumbGenIndex, "filePath");
            const thumbPath = root.getThumbPath(videoPath);
            root._thumbGenIndex++;
            // Check if file already exists, otherwise create it with ffmpeg
            if (root.thumbCacheFolderFiles.includes(thumbPath)) {
                Logger.d("video-wallpaper", `Creating thumbnail for video: ${videoPath}`);

                // With scale
                //thumbProc.command = ["sh", "-c", `ffmpeg -y -i ${videoUrl} -vf "scale=1080:-1" -vframes:v 1 ${thumbUrl}`]
                thumbProc.command = ["sh", "-c", `ffmpeg -y -i ${videoPath} -vframes:v 1 ${thumbPath}`]
                thumbProc.running = true;
                return;
            }
        }

        // The thumbnail generation has looped over every video and finished the generation
        thumbCacheFolderFiles = [];
        thumbCacheFolderFilesProc.running = true;

        root._thumbGenIndex = 0;
        setThumbCacheReady();
    }

    function thumbRegenerate() {
        if(pluginApi == null) return;

        pluginApi.pluginSettings.thumbCacheReady = false;
        pluginApi.saveSettings();

        thumbProc.command = ["sh", "-c", `rm -rf ${thumbCacheFolder} && mkdir -p ${thumbCacheFolder}`]
        thumbProc.running = true;
    }


    /***************************
    * COMPONENTS
    ***************************/
    Process {
        // Process to create the thumbnail folder
        id: thumbInit
        command: ["sh", "-c", `mkdir -p ${root.thumbCacheFolder}`]
        running: true
    }

    Process {
        id: thumbProc
        onRunningChanged: {
            if (thumbProc.running)
                return;

            // Try to create the thumbnails if they don't exist.
            root.thumbGeneration();
        }
    }

    Process {
        id: thumbCacheFolderFilesProc
        command: ["sh", "-c", `find ${root.thumbCacheFolder} -name "*.bmp"`]
        running: true
        stdout: SplitParser {
            onRead: line => {
                root.thumbCacheFolderFiles.push(line);
                Logger.d("video-wallpaper", line);
            }
        }
    }

    Timer {
        id: thumbColorGenTimer
        interval: 50
        repeat: false
        running: false
        triggeredOnStart: false

        onTriggered: { 
            const thumbPath = root.getThumbPath(root.currentWallpaper);
            if (root.thumbCacheFolderFiles.includes(thumbPath)) {
                Logger.d("video-wallpaper", "Generating color scheme based on video wallpaper!");
                WallpaperService.changeWallpaper(thumbPath);
            } else {
                // Try to create the thumbnail again
                // just a fail safe if the current wallpaper isn't included in the wallpapers folder
                const videoPath = folderModel.get(root._thumbGenIndex, "filePath");
                const thumbUrl = root.getThumbPath(videoPath);

                Logger.d("video-wallpaper", "Thumbnail not found:", thumbPath);
                thumbColorGenTimerProc.command = ["sh", "-c", `ffmpeg -y -i ${videoPath} -vframes:v 1 ${thumbUrl}`]
                thumbColorGenTimerProc.running = true;

                // Restart this timer
                thumbColorGenTimer.restart();
            }
        }
    }

    Process {
        id: thumbColorGenTimerProc
        onExited: thumbColorGenTimer.start();
    }
}
