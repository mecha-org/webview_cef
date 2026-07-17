// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mechanix Browser';

  @override
  String get searchOrEnterAddress => 'Search or enter address';

  @override
  String get newTab => 'New tab';

  @override
  String get newPrivateTab => 'New Private Tab';

  @override
  String get history => 'History';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get downloads => 'Downloads';

  @override
  String get share => 'Share';

  @override
  String get desktopSite => 'Desktop site';

  @override
  String get settings => 'Settings';

  @override
  String get closeAll => 'Close all';

  @override
  String comingSoon(String feature) {
    return '$feature is Coming Soon';
  }

  @override
  String get workingHard => 'We\'re working hard to bring this feature to you.';

  @override
  String get privateTabOpened => 'Private tab opened';

  @override
  String get sharingPage => 'Sharing page...';

  @override
  String get pageBookmarked => 'Page bookmarked';

  @override
  String get desktopSiteEnabled => 'Desktop site enabled';

  @override
  String get desktopSiteDisabled => 'Desktop site disabled';

  @override
  String noRouteDefined(String routeName) {
    return 'No route defined for $routeName';
  }
}
