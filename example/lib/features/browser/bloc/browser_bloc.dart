import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef/webview_cef.dart';
import '../../../core/utils/constants.dart';

part 'browser_event.dart';
part 'browser_state.dart';

class BrowserBloc extends Bloc<BrowserEvent, BrowserState> {
  late final WebViewController _controller;

  WebViewController get controller => _controller;

  BrowserBloc() : super(BrowserState.initial()) {
    final injectUserScripts = InjectUserScripts();
    injectUserScripts.add(UserScript("console.log('injectScript_in_LoadStart')",
        ScriptInjectTime.LOAD_START));
    injectUserScripts.add(UserScript(
        "console.log('injectScript_in_LoadEnd')", ScriptInjectTime.LOAD_END));

    _controller = WebviewManager().createWebView(
        loading: const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
        injectUserScripts: injectUserScripts);

    on<BrowserInitialized>(_onInitialized);
    on<BrowserUrlLoadRequested>(_onUrlLoadRequested);
    on<BrowserGoBackRequested>(_onGoBack);
    on<BrowserGoForwardRequested>(_onGoForward);
    on<BrowserReloadRequested>(_onReload);
    on<BrowserDevToolsRequested>(_onDevTools);
    on<BrowserGoHomeRequested>(_onGoHome);
    on<BrowserUrlChanged>(_onUrlChanged);
    on<BrowserTitleChanged>(_onTitleChanged);
  }

  Future<void> _onInitialized(
    BrowserInitialized event,
    Emitter<BrowserState> emit,
  ) async {
    try {
      await WebviewManager().initialize(userAgent: AppConstants.defaultUserAgent);

      final listener = WebviewEventsListener(
        onTitleChanged: (t) {
          add(BrowserTitleChanged(t));
        },
        onUrlChanged: (url) {
          add(BrowserUrlChanged(url));

          final Set<JavascriptChannel> jsChannels = {
            JavascriptChannel(
                name: 'Print',
                onMessageReceived: (JavascriptMessage message) {
                  debugPrint(message.message);
                  _controller.sendJavaScriptChannelCallBack(
                      false,
                      "{'code':'200','message':'print succeed!'}",
                      message.callbackId,
                      message.frameId);
                }),
          };
          _controller.setJavaScriptChannels(jsChannels);
          _controller.executeJavaScript("function abc(e){return 'abc:'+ e}");
          _controller
              .evaluateJavascript("abc('test')")
              .then((value) => debugPrint(value));
        },
        onLoadStart: (controller, url) {
          debugPrint("onLoadStart => $url");
        },
        onLoadEnd: (controller, url) {
          debugPrint("onLoadEnd => $url");
        },
      );

      _controller.setWebviewListener(listener);
      await _controller.initialize(AppConstants.homepageUrl);

      emit(state.copyWith(isInitialized: true));
    } catch (e) {
      debugPrint("Webview initialization error: $e");
    }
  }

  Future<void> _onUrlLoadRequested(
    BrowserUrlLoadRequested event,
    Emitter<BrowserState> emit,
  ) async {
    if (!state.isInitialized) return;

    String finalUrl = event.url.trim();
    if (finalUrl.isEmpty) return;

    if (!finalUrl.startsWith(RegExp(r'[a-zA-Z]+://'))) {
      if (finalUrl.contains('.') && !finalUrl.contains(' ')) {
        finalUrl = '${AppConstants.defaultScheme}$finalUrl';
      } else {
        finalUrl =
            '${AppConstants.searchUrlPrefix}${Uri.encodeComponent(finalUrl)}';
      }
    }

    emit(state.copyWith(isHomePage: false, currentUrl: finalUrl));
    if (_controller.value) {
      await _controller.loadUrl(finalUrl);
    }
  }

  Future<void> _onGoBack(
      BrowserGoBackRequested event, Emitter<BrowserState> emit) async {
    if (_controller.value) {
      await _controller.goBack();
    }
  }

  Future<void> _onGoForward(
      BrowserGoForwardRequested event, Emitter<BrowserState> emit) async {
    if (_controller.value) {
      await _controller.goForward();
    }
  }

  Future<void> _onReload(
      BrowserReloadRequested event, Emitter<BrowserState> emit) async {
    if (_controller.value) {
      await _controller.reload();
    }
  }

  Future<void> _onDevTools(
      BrowserDevToolsRequested event, Emitter<BrowserState> emit) async {
    if (_controller.value) {
      await _controller.openDevTools();
    }
  }

  Future<void> _onGoHome(
      BrowserGoHomeRequested event, Emitter<BrowserState> emit) async {
    emit(state.copyWith(isHomePage: true, currentUrl: ''));
    if (_controller.value) {
      await _controller.loadUrl(AppConstants.homepageUrl);
    }
  }

  void _onUrlChanged(BrowserUrlChanged event, Emitter<BrowserState> emit) {
    if (event.url != AppConstants.homepageUrl && event.url.isNotEmpty) {
      emit(state.copyWith(
        isHomePage: false,
        currentUrl: event.url,
      ));
    }
  }

  void _onTitleChanged(BrowserTitleChanged event, Emitter<BrowserState> emit) {
    emit(state.copyWith(title: event.title));
  }

  @override
  Future<void> close() async {
    _controller.dispose();
    await WebviewManager().quit();
    return super.close();
  }
}
