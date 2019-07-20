cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
  {
    "id": "cordova-plugin-siri-shortcuts.SiriVoiceKit",
    "file": "plugins/cordova-plugin-siri-shortcuts/www/SiriShortcuts.js",
    "pluginId": "cordova-plugin-siri-shortcuts",
    "clobbers": [
      "cordova.plugins.SiriShortcuts"
    ]
  }
];
module.exports.metadata = 
// TOP OF METADATA
{
  "cordova-plugin-add-swift-support": "1.7.2",
  "cordova-plugin-siri-shortcuts": "0.0.9",
  "cordova-plugin-whitelist": "1.3.3"
};
// BOTTOM OF METADATA
});