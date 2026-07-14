import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';

class BrowserWebviewBody extends StatelessWidget {
  const BrowserWebviewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<BrowserBloc>().controller;
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            return controller.value
                ? Expanded(child: controller.webviewWidget)
                : controller.loadingWidget;
          },
        ),
      ],
    );
  }
}
