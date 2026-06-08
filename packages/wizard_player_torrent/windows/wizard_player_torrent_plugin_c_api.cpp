#include "include/wizard_player_torrent/wizard_player_torrent_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "wizard_player_torrent_plugin.h"

void WizardPlayerTorrentPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  wizard_player_torrent::WizardPlayerTorrentPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
