import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wizard Player'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full Screen'**
  String get fullScreen;

  /// No description provided for @exitFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Full Screen'**
  String get exitFullScreen;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search anime...'**
  String get searchPlaceholder;

  /// No description provided for @videoDetail.
  ///
  /// In en, this message translates to:
  /// **'Video Detail'**
  String get videoDetail;

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// No description provided for @selectEpisode.
  ///
  /// In en, this message translates to:
  /// **'Select Episode'**
  String get selectEpisode;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// No description provided for @episodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {number}'**
  String episodeNumber(int number);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadError;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @anime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get anime;

  /// No description provided for @koreanDrama.
  ///
  /// In en, this message translates to:
  /// **'Korean Drama'**
  String get koreanDrama;

  /// No description provided for @americanDrama.
  ///
  /// In en, this message translates to:
  /// **'American Drama'**
  String get americanDrama;

  /// No description provided for @japaneseDrama.
  ///
  /// In en, this message translates to:
  /// **'Japanese Drama'**
  String get japaneseDrama;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @latestUpdate.
  ///
  /// In en, this message translates to:
  /// **'Latest Update'**
  String get latestUpdate;

  /// No description provided for @continueWatching.
  ///
  /// In en, this message translates to:
  /// **'Continue Watching'**
  String get continueWatching;

  /// No description provided for @todayUpdate.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Update'**
  String get todayUpdate;

  /// No description provided for @weeklyRanking.
  ///
  /// In en, this message translates to:
  /// **'Weekly Ranking'**
  String get weeklyRanking;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @enterKeywordToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword to search anime'**
  String get enterKeywordToSearch;

  /// No description provided for @foundResults.
  ///
  /// In en, this message translates to:
  /// **'Found {count} results'**
  String foundResults(int count);

  /// No description provided for @playbackPosition.
  ///
  /// In en, this message translates to:
  /// **'Playback position: {position}'**
  String playbackPosition(String position);

  /// No description provided for @startPlay.
  ///
  /// In en, this message translates to:
  /// **'Start Play'**
  String get startPlay;

  /// No description provided for @continuePlay.
  ///
  /// In en, this message translates to:
  /// **'Continue Episode {number}'**
  String continuePlay(int number);

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @relatedRecommend.
  ///
  /// In en, this message translates to:
  /// **'Related Recommendations'**
  String get relatedRecommend;

  /// No description provided for @noUpdateToday.
  ///
  /// In en, this message translates to:
  /// **'No update today'**
  String get noUpdateToday;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @movie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get movie;

  /// No description provided for @tvSeries.
  ///
  /// In en, this message translates to:
  /// **'TV Series'**
  String get tvSeries;

  /// No description provided for @noPlayHistory.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t watched any anime yet, go check out what\'s good...'**
  String get noPlayHistory;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all history?'**
  String get clearHistoryConfirm;

  /// No description provided for @clearAllHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear All History'**
  String get clearAllHistory;

  /// No description provided for @getVideoList.
  ///
  /// In en, this message translates to:
  /// **'Getting {type} video list, page {page}'**
  String getVideoList(String type, int page);

  /// No description provided for @getVideoDetail.
  ///
  /// In en, this message translates to:
  /// **'Getting video detail, ID: {videoId}'**
  String getVideoDetail(String videoId);

  /// No description provided for @searchVideo.
  ///
  /// In en, this message translates to:
  /// **'Searching video, keyword: {keyword}'**
  String searchVideo(String keyword);

  /// No description provided for @getPlayHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get play history'**
  String get getPlayHistoryFailed;

  /// No description provided for @getVideoHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get video history'**
  String get getVideoHistoryFailed;

  /// No description provided for @savePlayHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Play history saved successfully, video ID: {videoId}'**
  String savePlayHistorySuccess(String videoId);

  /// No description provided for @savePlayHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save play history'**
  String get savePlayHistoryFailed;

  /// No description provided for @deletePlayHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Play history deleted successfully, history ID: {historyId}'**
  String deletePlayHistorySuccess(String historyId);

  /// No description provided for @deletePlayHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete play history'**
  String get deletePlayHistoryFailed;

  /// No description provided for @clearAllPlayHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'All play history cleared successfully'**
  String get clearAllPlayHistorySuccess;

  /// No description provided for @clearAllPlayHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear play history'**
  String get clearAllPlayHistoryFailed;

  /// No description provided for @initPlayerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize player'**
  String get initPlayerFailed;

  /// No description provided for @noAvailableSources.
  ///
  /// In en, this message translates to:
  /// **'No available sources'**
  String get noAvailableSources;

  /// No description provided for @initVideoPlayerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize video player'**
  String get initVideoPlayerFailed;

  /// No description provided for @autoPlayNextEpisode.
  ///
  /// In en, this message translates to:
  /// **'Auto playing next episode: {episodeNumber}'**
  String autoPlayNextEpisode(int episodeNumber);

  /// No description provided for @resumePlayPosition.
  ///
  /// In en, this message translates to:
  /// **'Resumed playback position: {position} seconds'**
  String resumePlayPosition(int position);

  /// No description provided for @loadPlayPositionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load playback position'**
  String get loadPlayPositionFailed;

  /// No description provided for @savePlayPositionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save playback position'**
  String get savePlayPositionFailed;

  /// No description provided for @episodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Episode {episodeNumber} not found'**
  String episodeNotFound(int episodeNumber);

  /// No description provided for @switchEpisodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch episode'**
  String get switchEpisodeFailed;

  /// No description provided for @sourceNotFoundOrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Source not found or unavailable: {sourceId}'**
  String sourceNotFoundOrUnavailable(String sourceId);

  /// No description provided for @switchSourceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch source'**
  String get switchSourceFailed;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A cross-platform Flutter app that supports online video and BT torrent playback'**
  String get appDescription;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @searchingSource.
  ///
  /// In en, this message translates to:
  /// **'Searching for sources...'**
  String get searchingSource;

  /// No description provided for @episodesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} episodes'**
  String episodesCount(int count);

  /// No description provided for @selectEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get selectEpisodes;

  /// No description provided for @relatedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Related Recommendations'**
  String get relatedRecommendations;

  /// Test video title
  ///
  /// In en, this message translates to:
  /// **'Test Video'**
  String get testVideo;

  /// Big Buck Bunny test video name
  ///
  /// In en, this message translates to:
  /// **'Big Buck Bunny'**
  String get bigBuckBunny;

  /// Test online video playback description
  ///
  /// In en, this message translates to:
  /// **'Test online video playback'**
  String get testOnlineVideoPlay;

  /// Test video description
  ///
  /// In en, this message translates to:
  /// **'Playable in China'**
  String get testVideoDescription;

  /// Search anime
  ///
  /// In en, this message translates to:
  /// **'Search Anime'**
  String get searchAnime;

  /// Enter keyword to search anime hint
  ///
  /// In en, this message translates to:
  /// **'Enter keyword to search anime'**
  String get enterKeywordToSearchAnime;

  /// No resources found
  ///
  /// In en, this message translates to:
  /// **'No playback resources found for this anime'**
  String get noResourceFound;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'Found {count} results'**
  String searchResultCount(int count);

  /// No description provided for @tryGetVideoDetail.
  ///
  /// In en, this message translates to:
  /// **'Trying to get video detail from {source}, ID: {id}'**
  String tryGetVideoDetail(String source, String id);

  /// No description provided for @videoDetailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video detail obtained successfully, {count} episodes'**
  String videoDetailSuccess(int count);

  /// Failed to get video detail
  ///
  /// In en, this message translates to:
  /// **'Failed to get video detail'**
  String get getVideoDetailFailed;

  /// No description provided for @searchResultsHaveEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Search results already have {count} episodes'**
  String searchResultsHaveEpisodes(int count);

  /// No description provided for @episodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Episode {index}'**
  String episodePrefix(int index);

  /// No description provided for @jumpToPlayer.
  ///
  /// In en, this message translates to:
  /// **'Jumping to player, episode: {episodeNumber}'**
  String jumpToPlayer(int episodeNumber);

  /// Failed to search resources
  ///
  /// In en, this message translates to:
  /// **'Failed to search resources'**
  String get searchResourceFailed;

  /// Load failed
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// Error searching for playback resources
  ///
  /// In en, this message translates to:
  /// **'Error searching for playback resources, please try again'**
  String get searchResourceError;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @seekBackward.
  ///
  /// In en, this message translates to:
  /// **'-10s'**
  String get seekBackward;

  /// No description provided for @seekForward.
  ///
  /// In en, this message translates to:
  /// **'+10s'**
  String get seekForward;

  /// No description provided for @volumePercent.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent}%'**
  String volumePercent(int percent);

  /// No description provided for @windowFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Window Fullscreen'**
  String get windowFullscreen;

  /// No description provided for @exitWindowFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Window Fullscreen'**
  String get exitWindowFullscreen;

  /// No description provided for @screenFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Screen Fullscreen (Esc to exit)'**
  String get screenFullscreen;

  /// No description provided for @exitScreenFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Screen Fullscreen'**
  String get exitScreenFullscreen;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get keyboardShortcuts;

  /// No description provided for @spacePlayPause.
  ///
  /// In en, this message translates to:
  /// **'Space: Play/Pause'**
  String get spacePlayPause;

  /// No description provided for @arrowKeysSeek.
  ///
  /// In en, this message translates to:
  /// **'Arrow Keys: Seek/Volume'**
  String get arrowKeysSeek;

  /// No description provided for @keyWWindowFullscreen.
  ///
  /// In en, this message translates to:
  /// **'W: Window Fullscreen'**
  String get keyWWindowFullscreen;

  /// No description provided for @keyFScreenFullscreen.
  ///
  /// In en, this message translates to:
  /// **'F: Screen Fullscreen'**
  String get keyFScreenFullscreen;

  /// No description provided for @keyEscExitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Esc: Exit Fullscreen'**
  String get keyEscExitFullscreen;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @loadHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get loadHistoryFailed;

  /// No description provided for @loadedPlayHistory.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} play history records'**
  String loadedPlayHistory(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
