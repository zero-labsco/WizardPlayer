// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wizard Player';

  @override
  String get home => 'Home';

  @override
  String get discover => 'Discover';

  @override
  String get history => 'History';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favorites';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get fullScreen => 'Full Screen';

  @override
  String get exitFullScreen => 'Exit Full Screen';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get followSystem => 'Follow System';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get search => 'Search';

  @override
  String get searchPlaceholder => 'Search anime...';

  @override
  String get videoDetail => 'Video Detail';

  @override
  String get episodes => 'Episodes';

  @override
  String get selectEpisode => 'Select Episode';

  @override
  String get sources => 'Sources';

  @override
  String episodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get loadError => 'Load failed';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get anime => 'Anime';

  @override
  String get koreanDrama => 'Korean Drama';

  @override
  String get americanDrama => 'American Drama';

  @override
  String get japaneseDrama => 'Japanese Drama';

  @override
  String get recommended => 'Recommended';

  @override
  String get popular => 'Popular';

  @override
  String get latest => 'Latest';

  @override
  String get latestUpdate => 'Latest Update';

  @override
  String get continueWatching => 'Continue Watching';

  @override
  String get todayUpdate => 'Today\'s Update';

  @override
  String get weeklyRanking => 'Weekly Ranking';

  @override
  String get noResults => 'No results found';

  @override
  String get enterKeywordToSearch => 'Enter keyword to search anime';

  @override
  String foundResults(int count) {
    return 'Found $count results';
  }

  @override
  String playbackPosition(String position) {
    return 'Playback position: $position';
  }

  @override
  String get startPlay => 'Start Play';

  @override
  String continuePlay(int number) {
    return 'Continue Episode $number';
  }

  @override
  String get introduction => 'Introduction';

  @override
  String get tags => 'Tags';

  @override
  String get relatedRecommend => 'Related Recommendations';

  @override
  String get noUpdateToday => 'No update today';

  @override
  String get category => 'Category';

  @override
  String get movie => 'Movie';

  @override
  String get tvSeries => 'TV Series';

  @override
  String get noPlayHistory =>
      'You haven\'t watched any anime yet, go check out what\'s good...';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to clear all history?';

  @override
  String get clearAllHistory => 'Clear All History';

  @override
  String get searchAnime => 'Search Anime';

  @override
  String getVideoList(String type, int page) {
    return 'Getting $type video list, page $page';
  }

  @override
  String getVideoDetail(String videoId) {
    return 'Getting video detail, ID: $videoId';
  }

  @override
  String searchVideo(String keyword) {
    return 'Searching video, keyword: $keyword';
  }

  @override
  String get getPlayHistoryFailed => 'Failed to get play history';

  @override
  String get getVideoHistoryFailed => 'Failed to get video history';

  @override
  String savePlayHistorySuccess(String videoId) {
    return 'Play history saved successfully, video ID: $videoId';
  }

  @override
  String get savePlayHistoryFailed => 'Failed to save play history';

  @override
  String deletePlayHistorySuccess(String historyId) {
    return 'Play history deleted successfully, history ID: $historyId';
  }

  @override
  String get deletePlayHistoryFailed => 'Failed to delete play history';

  @override
  String get clearAllPlayHistorySuccess =>
      'All play history cleared successfully';

  @override
  String get clearAllPlayHistoryFailed => 'Failed to clear play history';

  @override
  String get initPlayerFailed => 'Failed to initialize player';

  @override
  String get noAvailableSources => 'No available sources';

  @override
  String get initVideoPlayerFailed => 'Failed to initialize video player';

  @override
  String autoPlayNextEpisode(int episodeNumber) {
    return 'Auto playing next episode: $episodeNumber';
  }

  @override
  String resumePlayPosition(int position) {
    return 'Resumed playback position: $position seconds';
  }

  @override
  String get loadPlayPositionFailed => 'Failed to load playback position';

  @override
  String get savePlayPositionFailed => 'Failed to save playback position';

  @override
  String episodeNotFound(int episodeNumber) {
    return 'Episode $episodeNumber not found';
  }

  @override
  String get switchEpisodeFailed => 'Failed to switch episode';

  @override
  String sourceNotFoundOrUnavailable(String sourceId) {
    return 'Source not found or unavailable: $sourceId';
  }

  @override
  String get switchSourceFailed => 'Failed to switch source';

  @override
  String get about => 'About';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';
}
