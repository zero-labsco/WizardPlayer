// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Wizard Player';

  @override
  String get home => '首页';

  @override
  String get discover => '发现';

  @override
  String get history => '历史';

  @override
  String get favorite => '收藏';

  @override
  String get favorites => '收藏';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get fullScreen => '全屏';

  @override
  String get exitFullScreen => '退出全屏';

  @override
  String get previous => '上一集';

  @override
  String get next => '下一集';

  @override
  String get clearHistory => '清除历史记录';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get darkMode => '深色模式';

  @override
  String get followSystem => '跟随系统';

  @override
  String get language => '语言';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get search => '搜索';

  @override
  String get searchPlaceholder => '搜索番剧...';

  @override
  String get videoDetail => '视频详情';

  @override
  String get episodes => '集数';

  @override
  String get selectEpisode => '选集';

  @override
  String get sources => '源';

  @override
  String episodeNumber(int number) {
    return '第$number集';
  }

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get loadError => '加载失败';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get anime => '动漫';

  @override
  String get koreanDrama => '韩剧';

  @override
  String get americanDrama => '美剧';

  @override
  String get japaneseDrama => '日剧';

  @override
  String get recommended => '推荐';

  @override
  String get popular => '热门';

  @override
  String get latest => '最新';

  @override
  String get latestUpdate => '最新更新';

  @override
  String get continueWatching => '继续观看';

  @override
  String get todayUpdate => '今日更新';

  @override
  String get weeklyRanking => '本周排行';

  @override
  String get noResults => '未找到相关结果';

  @override
  String get enterKeywordToSearch => '输入关键词搜索番剧';

  @override
  String foundResults(int count) {
    return '找到 $count 个结果';
  }

  @override
  String playbackPosition(String position) {
    return '播放位置: $position';
  }

  @override
  String get startPlay => '开始播放';

  @override
  String continuePlay(int number) {
    return '继续观看 第 $number 集';
  }

  @override
  String get introduction => '简介';

  @override
  String get tags => '标签';

  @override
  String get relatedRecommend => '相关推荐';

  @override
  String get noUpdateToday => '今日没有更新';

  @override
  String get category => '分类';

  @override
  String get movie => '电影';

  @override
  String get tvSeries => '电视剧';

  @override
  String get noPlayHistory => '还没有在看的番剧，去看看有什么好番吧...';

  @override
  String get noFavorites => '暂无收藏';

  @override
  String get clearHistoryConfirm => '确定要清除所有历史记录吗？';

  @override
  String get clearAllHistory => '清除所有历史';

  @override
  String getVideoList(String type, int page) {
    return '获取$type视频列表，第$page页';
  }

  @override
  String getVideoDetail(String videoId) {
    return '获取视频详情，ID: $videoId';
  }

  @override
  String searchVideo(String keyword) {
    return '搜索视频，关键词: $keyword';
  }

  @override
  String get getPlayHistoryFailed => '获取播放历史失败';

  @override
  String get getVideoHistoryFailed => '获取视频历史记录失败';

  @override
  String savePlayHistorySuccess(String videoId) {
    return '保存播放历史成功，视频ID: $videoId';
  }

  @override
  String get savePlayHistoryFailed => '保存播放历史失败';

  @override
  String deletePlayHistorySuccess(String historyId) {
    return '删除播放历史成功，历史ID: $historyId';
  }

  @override
  String get deletePlayHistoryFailed => '删除播放历史失败';

  @override
  String get clearAllPlayHistorySuccess => '清除所有播放历史成功';

  @override
  String get clearAllPlayHistoryFailed => '清除播放历史失败';

  @override
  String get initPlayerFailed => '初始化播放器失败';

  @override
  String get noAvailableSources => '没有可用的播放源';

  @override
  String get initVideoPlayerFailed => '初始化视频播放器失败';

  @override
  String autoPlayNextEpisode(int episodeNumber) {
    return '自动播放下一集: $episodeNumber';
  }

  @override
  String resumePlayPosition(int position) {
    return '恢复播放位置: $position秒';
  }

  @override
  String get loadPlayPositionFailed => '加载播放位置失败';

  @override
  String get savePlayPositionFailed => '保存播放位置失败';

  @override
  String episodeNotFound(int episodeNumber) {
    return '未找到第$episodeNumber集';
  }

  @override
  String get switchEpisodeFailed => '切换集数失败';

  @override
  String sourceNotFoundOrUnavailable(String sourceId) {
    return '未找到可用的源: $sourceId';
  }

  @override
  String get switchSourceFailed => '切换播放源失败';

  @override
  String get about => '关于';

  @override
  String get appDescription => '一个支持在线视频和 BT 种子播放的 Flutter 跨平台应用';

  @override
  String get ok => '确定';

  @override
  String get searchingSource => '正在搜索资源...';

  @override
  String episodesCount(int count) {
    return '$count 集';
  }

  @override
  String get selectEpisodes => '选集';

  @override
  String get relatedRecommendations => '相关推荐';

  @override
  String get testVideo => '测试视频';

  @override
  String get bigBuckBunny => 'Big Buck Bunny';

  @override
  String get testOnlineVideoPlay => '测试在线视频播放';

  @override
  String get testVideoDescription => '国内可播放';

  @override
  String get searchAnime => '搜索番剧';

  @override
  String get enterKeywordToSearchAnime => '输入关键词搜索番剧';

  @override
  String get noResourceFound => '暂时没有找到这个番剧的播放资源';

  @override
  String searchResultCount(int count) {
    return '搜索到 $count 个结果';
  }

  @override
  String tryGetVideoDetail(String source, String id) {
    return '尝试从 $source 获取视频详情，ID: $id';
  }

  @override
  String videoDetailSuccess(int count) {
    return '视频详情获取成功，剧集数: $count';
  }

  @override
  String get getVideoDetailFailed => '获取视频详情失败';

  @override
  String searchResultsHaveEpisodes(int count) {
    return '搜索结果已有 $count 个剧集';
  }

  @override
  String episodePrefix(int index) {
    return '第$index集';
  }

  @override
  String jumpToPlayer(int episodeNumber) {
    return '跳转到播放器，剧集号: $episodeNumber';
  }

  @override
  String get searchResourceFailed => '搜索资源失败';

  @override
  String get loadFailed => '加载失败';

  @override
  String get searchResourceError => '搜索播放资源时出错，请重试';

  @override
  String get sunday => '周日';

  @override
  String get monday => '周一';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String get saturday => '周六';
}
