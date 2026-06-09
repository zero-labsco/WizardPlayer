library wizard_player_media;

import 'package:media_kit/media_kit.dart';

export 'player/playback_state.dart';
export 'player/wizard_player.dart';
export 'player/media_kit_impl.dart';
export 'widgets/wizard_player_widget.dart';
export 'widgets/fullscreen_player_route.dart';

/// 必须在应用启动（如 main.dart）时调用
/// 完成 libmpv 的初始化
void ensureWizardPlayerMediaInitialized() {
  MediaKit.ensureInitialized();
}
