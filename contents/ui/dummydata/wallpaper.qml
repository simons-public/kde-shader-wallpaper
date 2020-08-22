import QtQuick 2

Item {
    id: wallpaper
    property alias configuration: itemConfiguration

    Item {
        id: itemConfiguration
        property string selectedShader: "./Shader/Shader_Waves.qml"
    }


}