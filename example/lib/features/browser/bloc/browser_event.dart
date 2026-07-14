part of 'browser_bloc.dart';

sealed class BrowserEvent extends Equatable {
  const BrowserEvent();

  @override
  List<Object?> get props => [];
}

class BrowserInitialized extends BrowserEvent {}

class BrowserUrlLoadRequested extends BrowserEvent {
  final String url;
  const BrowserUrlLoadRequested(this.url);

  @override
  List<Object?> get props => [url];
}

class BrowserGoBackRequested extends BrowserEvent {}

class BrowserGoForwardRequested extends BrowserEvent {}

class BrowserReloadRequested extends BrowserEvent {}

class BrowserDevToolsRequested extends BrowserEvent {}

class BrowserGoHomeRequested extends BrowserEvent {}

class BrowserUrlChanged extends BrowserEvent {
  final String url;
  const BrowserUrlChanged(this.url);

  @override
  List<Object?> get props => [url];
}

class BrowserTitleChanged extends BrowserEvent {
  final String title;
  const BrowserTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}
