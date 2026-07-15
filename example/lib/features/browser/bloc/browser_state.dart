part of 'browser_bloc.dart';

class BrowserState extends Equatable {
  final bool isInitialized;
  final bool isHomePage;
  final String currentUrl;
  final String title;
  final List<BrowserHistory> searchResults;

  const BrowserState({
    required this.isInitialized,
    required this.isHomePage,
    required this.currentUrl,
    required this.title,
    required this.searchResults,
  });

  factory BrowserState.initial() => const BrowserState(
        isInitialized: false,
        isHomePage: true,
        currentUrl: '',
        title: '',
        searchResults: [],
      );

  BrowserState copyWith({
    bool? isInitialized,
    bool? isHomePage,
    String? currentUrl,
    String? title,
    List<BrowserHistory>? searchResults,
  }) {
    return BrowserState(
      isInitialized: isInitialized ?? this.isInitialized,
      isHomePage: isHomePage ?? this.isHomePage,
      currentUrl: currentUrl ?? this.currentUrl,
      title: title ?? this.title,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        isHomePage,
        currentUrl,
        title,
        searchResults,
      ];
}
