part of 'browser_bloc.dart';

class BrowserState extends Equatable {
  final bool isInitialized;
  final bool isHomePage;
  final String currentUrl;
  final String title;

  const BrowserState({
    required this.isInitialized,
    required this.isHomePage,
    required this.currentUrl,
    required this.title,
  });

  factory BrowserState.initial() => const BrowserState(
        isInitialized: false,
        isHomePage: true,
        currentUrl: '',
        title: '',
      );

  BrowserState copyWith({
    bool? isInitialized,
    bool? isHomePage,
    String? currentUrl,
    String? title,
  }) {
    return BrowserState(
      isInitialized: isInitialized ?? this.isInitialized,
      isHomePage: isHomePage ?? this.isHomePage,
      currentUrl: currentUrl ?? this.currentUrl,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [isInitialized, isHomePage, currentUrl, title];
}
