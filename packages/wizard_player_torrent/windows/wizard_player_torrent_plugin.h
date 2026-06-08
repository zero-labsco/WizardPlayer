#ifndef FLUTTER_PLUGIN_WIZARD_PLAYER_TORRENT_PLUGIN_H_
#define FLUTTER_PLUGIN_WIZARD_PLAYER_TORRENT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace wizard_player_torrent {

class WizardPlayerTorrentPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WizardPlayerTorrentPlugin();

  virtual ~WizardPlayerTorrentPlugin();

  // Disallow copy and assign.
  WizardPlayerTorrentPlugin(const WizardPlayerTorrentPlugin&) = delete;
  WizardPlayerTorrentPlugin& operator=(const WizardPlayerTorrentPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace wizard_player_torrent

#endif  // FLUTTER_PLUGIN_WIZARD_PLAYER_TORRENT_PLUGIN_H_
